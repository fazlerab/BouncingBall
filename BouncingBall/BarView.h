//
//  BarView.h
//  Animation
//
//  Created by Imran on 2/19/16.
//  Copyright © 2016 Fazle Rab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarView : UIView

@property (nonatomic, copy) void(^updateBarLocation)(CGPoint);

@end
