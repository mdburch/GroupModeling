//
//  Model.m
//  GroupModelingApp
//
//  Created by Matthew Burch on 6/23/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import "Constants.h"
#import "EventLogger.h"
#import "Model.h"

@implementation Model

@synthesize components    = _components;
@synthesize defaultParams = _defaultParams;
@synthesize controlParams = _controlParams;
@synthesize startingHash  = _startingHash;
@synthesize endingHash    = _endingHash;

/// Forces the Model to be a singleton class.
/// @return a pointer to the single instance of the model.
+ (Model*)sharedModel {
    static Model *sharedModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedModel = [[self alloc] init];
        sharedModel.components    = [[NSMutableArray alloc]init];
        sharedModel.defaultParams = [[DefaultParameters alloc] init:@""];
        sharedModel.controlParams = [[ControlParameters alloc] init];
        sharedModel.startingHash  = [[NSData alloc]init];
        sharedModel.endingHash    = [[NSData alloc]init];
    });
    return sharedModel;
}

/// Clears the model when you need to create or load a brand new file.
-(void) clearModel
{
    // Remove the views representing the objects.
    for(Component* compo in self.components)
    {
        if([compo isMemberOfClass:[Loop class]])
        {
            [[(Loop*)compo view] removeFromSuperview];
        }
        else if([compo isMemberOfClass:[Variable class]])
        {
            [[(Variable*)compo view] removeFromSuperview];
        }
        else if([compo isMemberOfClass:[CausalLink class]])
        {
            [[(CausalLink*)compo view] removeFromSuperview];
        }
    }
    // Remove all components in the model.
    [self.components removeAllObjects];
    self.defaultParams.params = @"";
    [self.controlParams.params removeAllObjects];
    
    // Reset the id counter for a brand new model.
    [Component resetIDCounter];
    
    // Clear out the hashes.
    self.startingHash = [NSData data];
    self.endingHash   = [NSData data];
}

/// Constructs the details message for all moving events.
/// @param location the point where the object is located.
/// @return a string with the location.
-(NSString*) constructLocationDetails:(CGPoint) location
{
    return [[NSString alloc]initWithFormat:COORDINATES, (int)location.x, (int)location.y];
}

/// Iterates over all of the Variables in the model and constructs the Vensim Function of() map for each one.
/// @return an array of strings that hold all of the output text of the variable maps.
-(NSMutableArray*) createVariableMap
{
    NSMutableArray* map = [[NSMutableArray alloc]init];
    for(Component* compo in self.components)
    {
        if([compo isMemberOfClass:[Variable class]])
        {
            Variable* temp = (Variable*) compo;
            [map addObjectsFromArray:[temp createVarMap]];
        }
    }
    return map;
}

/// Constructs a list of output strings for every component.
/// @return an array of output strings for all components.
-(NSMutableArray*) createComponentsExport
{
    NSMutableArray* componentsExport = [[NSMutableArray alloc]init];
    for(Component* compo in self.components)
    {
        if([compo isMemberOfClass:[Loop class]])
        {
            [componentsExport addObject:[(Loop*)compo createLoopOutputString]];
        }
        else if([compo isMemberOfClass:[Variable class]])
        {
           [componentsExport addObject:[(Variable*)compo createVariableOutputString]];
        }
        else if([compo isMemberOfClass:[CausalLink class]])
        {
            [componentsExport addObject:[(CausalLink*)compo createCausalLinkOutputString]];
        }
    }
    
    return componentsExport;
}

/// Adds a newly created object to the list of components existing in the model.
/// @param obj an object that needs to be added to the model.  Will be either a CausalLink, Variable or a Loop.
-(void) addComponent:(id) obj
{
    [self.components addObject:obj];
}

/// Will add a new causalLink to the model given a parent and a child.  The link will be a straight line from the parent to the child.
/// @param parent the parent Variable of the causal link.
/// @param child the child Variable of the causal link.
/// @return the id number of the newly created causal link.
-(int) addCasualLinkWithParent:(Variable*) parent andChild:(Variable*) child
{
    // Create and add the new link.
    CausalLink* link = [[CausalLink alloc]initWithParent:parent andChild:child];
    [[Model sharedModel] addComponent:link];
    
    // Update the parent and child with their newly added link.
    [parent addOutdegreeLink:link];
    [child  addIndegreeLink:link];
    
    return link.idNum;
}

/// Searches the list of components for a Variable component with a specified id.
/// @param idNumber the id number of the Variable that is being searched for.
/// @return a pointer to a variable object with an id of idNumber.
-(Variable*) getVariable:(NSNumber*) idNumber
{
    Variable* obj = nil;

    for(Component* compo in self.components)
    {
        if([compo isMemberOfClass:[Variable class]])
        {
            if([compo idNum] == idNumber.integerValue)
            {
                obj = (Variable*) compo;
            }
        }
    }
    return obj;
}

/// Searches the list of components for a Variable component that contains the provided point.
/// @param point the point within the superview frame.
/// @return pointer to a Variable object  that contains the point, nil if none do.
-(Variable*) getVariableAtPoint:(CGPoint) point
{
    Variable* obj = nil;
    
    for(Component* compo in self.components)
    {
        if([compo isMemberOfClass:[Variable class]])
        {
                Variable* temp = (Variable*) compo;
         
            // Check to see if the point is in the frame.
            CGPoint locInFrame = CGPointMake(point.x - temp.view.frame.origin.x,
                                             point.y - temp.view.frame.origin.y);
            if((locInFrame.x > 0 && locInFrame.x <= temp.view.frame.size.width) &&
               (locInFrame.y > 0 && locInFrame.y <= temp.view.frame.size.height))
            {
                obj = temp;
            }
        }
    }
    return obj;
}

/// Searches the list of components for a CausalLink component with a specified CausalLinkView.
/// @param linkView the view associated with the CasualLink.
/// @return the id numbder of the causal link that was deleted for logging purposes.
-(int) deleteCausalLink:(id) linkView
{
    // Find the causal link
    CausalLink* link = nil;
    for(Component* compo in self.components)
    {
        if([compo isMemberOfClass:[CausalLink class]])
        {
            if([(CausalLink*)compo view] == linkView)
            {
                link = (CausalLink*)compo;
            }
        }
    }
    
    // Remove indegree and out degree link for the corresponding variables.
    [[link parentObject] removeOutdgreeLink:link];
    [[link childObject] removeIndgreeLink:link];
    
    // Remove the CausalLink from the model.
    int idNum = link.idNum;
    [self.components removeObject:link];
    [linkView removeFromSuperview];
    
    return idNum;
}

/// Searched the list of components for a Loop component with a specified LoopView.
/// @param loopView the view associated with the Loop.
/// @return the id numbder of the loop that was deleted for logging purposes.
-(int) deleteLoop:(id) loopView
{
    // Find the feedback loop
    Loop* loop = nil;
    for(Component* compo in self.components)
    {
        if([compo isMemberOfClass:[Loop class]])
        {
            if([(Loop*)compo view] == loopView)
            {
                loop = (Loop*)compo;
            }
        }
    }
    
    // Remove the Loop from the model.
    int idNum = loop.idNum;
    [self.components removeObject:loop];
    [loopView removeFromSuperview];
    
    return idNum;
}

/// Searched the list of components for a Variable component with a specified VariableView.
/// @param variableView the view associated with the Variable.
/// @return the id numbder of the variable that was deleted for logging purposes.
-(int) deleteVariable:(id) variableView
{
    // Find the variable
    Variable* var = nil;
    for(Component* compo in self.components)
    {
        if([compo isMemberOfClass:[Variable class]])
        {
            if([(Variable*)compo view] == variableView)
            {
                var = (Variable*)compo;
            }
        }
    }
    
    // Will log how many links were deleted and what the links were.
    int count = var.indegreeLinks.count + var.outdegreeLinks.count;
    NSMutableString* details = [[NSMutableString alloc] initWithFormat: NUMBER_DELETED, count];
    
    // Remove indegree links from the model.
    for(id link in var.indegreeLinks)
    {
        CausalLink* l = link;
        Variable* parent = l.parentObject;
        Variable* child  = l.childObject;
        [details appendFormat:@"id:%d ", l.idNum];
        [details appendFormat:PARENT_CHILD, parent.view.name, parent.idNum, child.view.name, child.idNum];
        
        // Remove the link from the parent object so it does not exist in the export.
        [l.parentObject removeOutdgreeLink:l];
        [self.components removeObject:link];
        [l.view removeFromSuperview];
    }
    
    // Remove outdegree links from the model.
    for(id link in var.outdegreeLinks)
    {
        CausalLink* l = link;
        Variable* parent = l.parentObject;
        Variable* child  = l.childObject;
        [details appendFormat:@"id:%d ", l.idNum];
        [details appendFormat:PARENT_CHILD, parent.view.name, parent.idNum, child.view.name, child.idNum];
        
        // Remove the link from the child object so it does not exist in the export.
        [l.childObject removeIndgreeLink:l];
        [self.components removeObject:link];
        [l.view removeFromSuperview];
    }
    
    // Log the details about the deleted links if there are links to delete.
    if(count != 0)
    {
        [[EventLogger sharedEventLogger]addEvent:[[Event alloc] initWithDescID:REMOVED_LINKS
                                                                   andObjectID:var.idNum
                                                                    andDetails:details]];
    }
    
    // Remove the Variable from the model.
    int idNum = var.idNum;
    [self.components removeObject:var];
    [variableView removeFromSuperview];
    
    return idNum;
}

/// Gets the root view controller view.
/// @return the currently displayed view controller view from the app delegate.
-(UIView*) getViewControllerView
{
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    MFSideMenuContainerViewController *parent = (MFSideMenuContainerViewController*) app.window.rootViewController;
    
    UINavigationController *navigationController = parent.centerViewController;
    

    return navigationController.visibleViewController.view;
}

/// Gets the view controller.
/// @return a pointer to the currently displayed view controller.
-(UIViewController*) getViewController
{
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    MFSideMenuContainerViewController *parent = (MFSideMenuContainerViewController*) app.window.rootViewController;
    
    UINavigationController *navigationController = parent.centerViewController;
    
    return (UIViewController*) navigationController.visibleViewController;
}

/// Searches the list of components for a Variable component with a specified VariableView and will move the attached CausalLinks.
/// @param variableView the view associated with the Variable.
-(void) moveVariable:(id) variableView
{
    VariableView* varView = variableView;
    // Find the variable
    Variable* var = nil;
    for(Component* compo in self.components)
    {
        if([compo isMemberOfClass:[Variable class]])
        {
            if([(Variable*)compo view] == variableView)
            {
                var = (Variable*)compo;
            }
        }
    }
    
    // Move indegree links touching the Variable.
    for(id link in var.indegreeLinks)
    {
        CausalLink* l = link;
        [l.view moveVariable:varView.center modifyStartPoint:NO];
    }

    // Move outdegree links touching the Variable.
    for(id link in var.outdegreeLinks)
    {
        CausalLink* l = link;
        [l.view moveVariable:varView.center modifyStartPoint:YES];
    }
}

/// Will iterate over all of the variables in the model and make a call to determine if the provided point lies within the bounds of the variable's view frame to change the box color.  This is used when a user is creating a new causal link.
/// @param location the point in the coordinate space user to determine if a variable contains that point.
-(void) setVariableColor:(CGPoint) location
{
    Variable* var = nil;
    for(Component* compo in self.components)
    {
        if([compo isMemberOfClass:[Variable class]])
        {
            var = (Variable*)compo;
            [var.view setBoxColorBasedOnPoint:location];
        }
    }
}

/// Will find the smallest frame that will contain the entire model.
/// Used for taking pictures of the model.
/// @return a CGRect of the frame of the entire model.
-(CGRect)findModelFrame
{
    // Variables used to store the minimum origin and maximum size.
    CGPoint origin = CGPointMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    CGSize size    = CGSizeZero;
    
    // Iterate over all of the components in the model.
    for(Component* compo in self.components)
    {
        CGRect rect;
        
        // Get the frame of the component based on its type.
        if([compo isMemberOfClass:[Variable class]])
        {
            rect = [(Variable*)compo view].frame;
        }
        else if([compo isMemberOfClass:[CausalLink class]])
        {
            rect = [(CausalLink*)compo view].frame;
        }
        else if([compo isMemberOfClass:[Loop class]])
        {
            rect = [(Loop*)compo view].frame;
        }
        
        // Check if the component's frame origin is less than the current origin.
        if(rect.origin.x < origin.x)
        {
            origin.x = rect.origin.x;
        }
        if(rect.origin.y < origin.y)
        {
            origin.y = rect.origin.y;
        }
        
        // Check if the component's frame size location is greater than the current size of the model.
        if(rect.origin.x + rect.size.width > size.width)
        {
            size.width = rect.origin.x + rect.size.width;
        }
        if(rect.origin.y + rect.size.height > size.height)
        {
            size.height = rect.origin.y + rect.size.height;
        }
        
    }
    
    return CGRectMake(origin.x-BUFFER, origin.y-BUFFER, size.width+BUFFER, size.height+BUFFER);
}
@end
