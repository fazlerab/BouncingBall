//
//  BarView.m
//  Animation
//
//  Created by Imran on 2/19/16.
//  Copyright © 2016 Fazle Rab. All rights reserved.
//

#import "BarView.h"

@interface BarView()

@property (nonatomic) CGPoint startLocation;

@end

@implementation BarView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.startLocation = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInView:self];
    float deltaX = location.x - self.startLocation.x;
    
    float newCenterX = self.center.x + deltaX;
    float barHalfWidth = self.bounds.size.width / 2;
    float superViewWidth = self.superview.bounds.size.width;
    
    if (newCenterX < barHalfWidth) {
        newCenterX = barHalfWidth;
    }
    if (newCenterX > (superViewWidth - barHalfWidth)) {
        newCenterX = superViewWidth - barHalfWidth;
    }
    
    CGPoint newCenterLocation = CGPointMake(newCenterX, self.center.y);
    self.updateBarLocation(newCenterLocation);
    
    //NSLog(@"location=%@, prevLocation=%@, deltaX=%f", NSStringFromCGPoint(location), NSStringFromCGPoint(self.startLocation),deltaX);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
