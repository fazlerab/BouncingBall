//
//  LoginViewController.m
//  Animation
//
//  Created by Imran on 3/2/16.
//  Copyright © 2016 Fazle Rab. All rights reserved.
//

#import "LoginViewController.h"

static NSString * const amazonhost = @"http://ec2-54-209-150-150.compute-1.amazonaws.com:8080/MyWebApp/login";
static NSString * const localhost = @"http://localhost:8084/MyWebApp/login";

static NSString * const UsernameKey = @"username";
static NSString * const PasswordKey = @"password";
static NSString * const AuthorizeKey = @"authorize";

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerYLayout;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIColor *borderColor = [UIColor colorWithRed:(64.0f/255.0f) green:0.0f blue:(128.0f/255.0f) alpha:1.0f];
    
    self.usernameTextField.layer.borderWidth = 1.0f;
    self.usernameTextField.layer.borderColor = borderColor.CGColor;
    self.usernameTextField.layer.cornerRadius = 5;
    //[self.usernameTextField becomeFirstResponder];
    
    self.passwordTextField.layer.borderWidth = 1.0f;
    self.passwordTextField.layer.borderColor = borderColor.CGColor;
    self.passwordTextField.layer.cornerRadius = 5.0;
    
    self.loginButton.layer.cornerRadius = 5;
    self.loginButton.enabled = false;
    [self.loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTextFieldChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAppearing:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAppearing:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDisappearing:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
*/

- (void)keyboardAppearing:(NSNotification *)notification {
    NSDictionary *userInfo = (NSDictionary *)notification.userInfo;
    
    CGRect kbFrame = ((NSValue *)userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
    NSTimeInterval interval = ((NSNumber *)userInfo[UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
    NSUInteger animationOption = ((NSNumber *)userInfo[UIKeyboardAnimationCurveUserInfoKey]).unsignedIntegerValue;
    
    CGRect kbFrameInView = [self.view convertRect:kbFrame fromView:self.view.window];
    float deltaY = CGRectGetMinY(kbFrameInView) - CGRectGetMaxY(self.stackView.frame); //NSLog(@"deltaY=%f", deltaY);
    
    if (deltaY > 0) return;
    
    self.centerYLayout.constant = deltaY - 8;
    
    [UIView animateWithDuration:interval delay:0 options:animationOption animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardDisappearing:(NSNotification *)notification {
    NSDictionary *userInfo = (NSDictionary *)notification.userInfo;
    
    NSTimeInterval interval = ((NSNumber *)userInfo[UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
    NSUInteger animationOption = ((NSNumber *)userInfo[UIKeyboardAnimationCurveUserInfoKey]).unsignedIntegerValue;
    
    self.centerYLayout.constant = 0;
    
    [UIView animateWithDuration:interval  delay:0.0 options:animationOption animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void) handleTextFieldChange:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    if (textField == self.usernameTextField || textField == self.passwordTextField) {
        BOOL isUsernameEmpty = [self.usernameTextField.text isEqualToString:@""];
        BOOL isPasswordEmpty = [self.passwordTextField.text isEqualToString:@""];
        
        [self.loginButton setEnabled:(!isUsernameEmpty && !isPasswordEmpty)];
    }
}

- (IBAction)logoutUnwindAcion:(UIStoryboardSegue *)unwindSegue {
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
    self.loginButton.enabled = NO;
}

- (IBAction)handleLogin:(UIButton *)sender {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [self loginWithUsername:username password:password completion:^(id response) {
        NSString *title, *message;
        
        if ([response isKindOfClass:[NSError class]]) {
            title = @"Error";
            message = ((NSError *)response).localizedDescription;
        }
        if ([response isKindOfClass:[NSString class]]) {
            BOOL authorize = [((NSString *)response) isEqualToString:@"true"];
            
            if (!authorize) {
                title = @"Login Error";
                message = @"Username or Password is incorrect.";
            }
            else {
                // Segue to game scene
                [self performSegueWithIdentifier:@"segueToGameScene" sender:self];
                return;
            }
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:action];
        [self showDetailViewController:alert sender:self];
    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(void(^)(id))completion {
    NSLog(@"username=%@, password=%@", username, password);
    
    // Configure parameter
    NSString *parameter = [NSString stringWithFormat:@"username=%@&password=%@", username, password];
    const char *bodyData = [parameter UTF8String];
    
    // Configure request
    NSURL *url = [NSURL URLWithString:amazonhost];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:bodyData length:strlen(bodyData)]];
    
    // Configure Session
    NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfiguration
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    // Configure data task
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            completion(error);
        }
        else {
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"result: %@", result);
            
            NSDictionary *propertyList = (NSDictionary *)[result propertyList];
            NSString *authorize = (NSString *)propertyList[AuthorizeKey];
            
            completion(authorize);
        }
    }];
    
    // Excute task
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
