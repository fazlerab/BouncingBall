//
//  ViewController.m
//  Animation
//
//  Created by Imran on 2/16/16.
//  Copyright © 2016 Fazle Rab. All rights reserved.
//

#import "GameViewController.h"
#import "BarView.h"

@interface GameViewController () <UICollisionBehaviorDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *ball;
@property (weak, nonatomic) IBOutlet BarView *bar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetButton;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;
//@property (strong, nonatomic) UIAttachmentBehavior *barAttachmentBehavior;

@property (nonatomic) int score;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.          
    [self initialize];
}

- (void)initialize {
    self.ball.layer.masksToBounds = YES;
    self.ball.layer.cornerRadius = 25;
    
    self.bar.layer.cornerRadius = 15;
    
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.animator = animator;

    typeof(self) __weak weakSelf = self;
    self.bar.updateBarLocation = ^(CGPoint newCenterLocation) {
        //weakSelf.barAttachmentBehavior.anchorPoint = newCenterLocation;
        weakSelf.bar.center = newCenterLocation;
        [weakSelf.animator updateItemUsingCurrentState:weakSelf.bar];
    };
    
    [self isRunning:NO];
    self.score = 0;
    [self updateScore];
}

- (void)addBehaviors {
    // Ball ItemBehavior
    UIDynamicItemBehavior *ballItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ball]];
    [ballItemBehavior setElasticity:1.0];
    [ballItemBehavior setFriction:0.0];
    [ballItemBehavior setResistance:0.0];
  //  [ballItemBehavior setDensity:0.0];
    [ballItemBehavior setAllowsRotation:YES];
    
    // Bar ItemBehavior
    UIDynamicItemBehavior *barItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.bar]];
    [barItemBehavior setElasticity:0.0];
    [barItemBehavior setFriction:0.0];
    [barItemBehavior setResistance:0.0];
   // [barItemBehavior setDensity:MAXFLOAT];
    [barItemBehavior setAnchored:YES];
    [barItemBehavior setAllowsRotation:NO];
    
    // Ball PushBehavior
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.ball] mode:UIPushBehaviorModeInstantaneous];
    [pushBehavior setAngle:[self randomRadianAngle] magnitude:(1.1)];
    
    // Ball and Bar CollisionBehavior
    float navBarHeight = self.navigationController.navigationBar.bounds.size.height;
    CGPoint origin = self.view.bounds.origin;
    CGSize size = self.view.bounds.size;
    
    CGPoint topLeftCorner     = CGPointMake(origin.x, origin.y + navBarHeight);
    CGPoint topRightCorner    = CGPointMake(origin.x + size.width, origin.y + navBarHeight);
    CGPoint bottomRightCorner = CGPointMake(origin.x + size.width, origin.y + size.height);
    CGPoint bottomLeftCorner  = CGPointMake(origin.x, origin.y + size.height);
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.ball, self.bar]];
    [collisionBehavior setTranslatesReferenceBoundsIntoBoundary:NO];
    [collisionBehavior setCollisionDelegate:self];
    
    [collisionBehavior addBoundaryWithIdentifier:@"topBoundary" fromPoint:topLeftCorner toPoint:topRightCorner];
    [collisionBehavior addBoundaryWithIdentifier:@"rightBoundary" fromPoint:topRightCorner toPoint:bottomRightCorner];
    //[collisionBehavior addBoundaryWithIdentifier:@"bottomBoundary" fromPoint:bottomRightCorner toPoint:bottomLeftCorner];
    [collisionBehavior addBoundaryWithIdentifier:@"leftBoundary" fromPoint:bottomLeftCorner toPoint:topLeftCorner];
    
    // Bar AttachmentBehavior
//    CGPoint anchor = self.bar.center;
//    CGVector axis = CGVectorMake(1.0, 0.0);
//    UIAttachmentBehavior *barAttachmentBehavior = [UIAttachmentBehavior slidingAttachmentWithItem:self.bar attachmentAnchor:anchor axisOfTranslation:axis];
//    [barAttachmentBehavior setAttachmentRange:UIFloatRangeMake(0.0, self.view.bounds.size.width)];
//    self.barAttachmentBehavior = barAttachmentBehavior;
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.ball]];
    gravityBehavior.magnitude = 0.1;
    
    // Add all behaviors
    [self.animator addBehavior:ballItemBehavior];
    [self.animator addBehavior:barItemBehavior];
    [self.animator addBehavior:pushBehavior];
    [self.animator addBehavior:collisionBehavior];
    //[self.animator addBehavior:barAttachmentBehavior];
    [self.animator addBehavior:gravityBehavior];
}

// MARK: UICollisionBehaviorDelegate methods
- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 {
    //NSLog(@"collision: %@",item2);
    if (item1 == self.bar || item2 == self.bar) {
        self.score++;
        [self updateScore];
    }
}

// MARK: Action methods
- (IBAction)handleReset:(UIBarButtonItem *)sender {
    [self.animator removeAllBehaviors];
    [self isRunning:NO];
    
    CGPoint center = self.view.center;
    self.ball.center = center;
    self.bar.center = CGPointMake(center.x, self.bar.center.y);
    
    self.score = 0;
    [self updateScore];
}

- (IBAction)handleStart:(UIBarButtonItem *)sender {
    [self addBehaviors];
    [self isRunning:YES];
}

- (void)isRunning:(BOOL)isRunning {
    self.startButton.enabled = !isRunning;
    self.resetButton.enabled = isRunning;
}

- (void) updateScore {
    self.title = [NSString stringWithFormat:@"Score: %d", self.score];
}

- (float) randomRadianAngle {
    float degree = arc4random_uniform(270) + 135;
    return degree * M_PI / 180.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
