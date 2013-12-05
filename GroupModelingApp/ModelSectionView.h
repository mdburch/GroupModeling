//
//  ModelSectionView.h
//  GroupModelingApp
//
//  Created by Matthew Burch on 7/18/13.
//  Copyright (c) 2013 Matthew Burch. All rights reserved.
//

#import <UIKit/UIKit.h>

/// A view that displays the Model and allows for modifications to the model.
@interface ModelSectionView : UIScrollView <UIScrollViewDelegate>

//@property UIView* canvas;

-(id)init;
-(void)drawRect:(CGRect)rect;
-(void)handleDoubleTap:(UITapGestureRecognizer *)sender;
-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
@end
