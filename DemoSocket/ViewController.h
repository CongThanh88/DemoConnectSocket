//
//  ViewController.h
//  DemoSocket
//
//  Created by Cong Thanh on 1/29/15.
//  Copyright (c) 2015 com.softfront. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/NSStream.h>

@interface ViewController : UIViewController<NSStreamDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblMyIP;
@property (weak, nonatomic) IBOutlet UITextField *txtIpConnect;
@property (weak, nonatomic) IBOutlet UITextView *txtComposeMessage;
@property (weak, nonatomic) IBOutlet UITextView *txtConversationView;

- (IBAction)btnSend:(id)sender;
- (IBAction)btnConnect:(id)sender;

@end

