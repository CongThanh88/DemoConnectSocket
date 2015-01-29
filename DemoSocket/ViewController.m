//
//  ViewController.m
//  DemoSocket
//
//  Created by Cong Thanh on 1/29/15.
//  Copyright (c) 2015 com.softfront. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initNetworkCommunicationToHost:(NSString*)host andPort:(NSInteger)port {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, (UInt32)port, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}


-(void)connectToHost:(NSString*)host port:(NSInteger)port
{
    [self initNetworkCommunicationToHost:host andPort:port];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSend:(id)sender {
    if (_txtComposeMessage.text) {
        
        NSData *data = [[NSData alloc] initWithData:[_txtComposeMessage.text dataUsingEncoding:NSASCIIStringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];
        
        NSString *sentString = [NSString stringWithFormat:@":Sent: %@",_txtComposeMessage.text];
        if (!_txtConversationView.text) {
            _txtConversationView.text = sentString;
        }else{
            _txtConversationView.text = [_txtConversationView.text stringByAppendingString:@"\n"];
            _txtConversationView.text = [_txtConversationView.text stringByAppendingString:sentString];
        }
    }
}

- (IBAction)btnConnect:(id)sender {
    if (_txtIpConnect.text) {
        [self connectToHost:_txtIpConnect.text port:8888];
    }
}

#pragma mark - NSStreamDelegate
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
            
        case NSStreamEventHasBytesAvailable:
            if (aStream == inputStream) {
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        if (nil != output) {
                            NSLog(@"server said: %@", output);
                            NSString *receivedString = [NSString stringWithFormat:@":Received: %@",output];
                            if (!_txtConversationView.text) {
                                _txtConversationView.text = receivedString;
                            }else{
                                _txtConversationView.text = [_txtConversationView.text stringByAppendingString:@"\n"];
                                _txtConversationView.text = [_txtConversationView.text stringByAppendingString:receivedString];
                            }
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            break;
            
        case NSStreamEventEndEncountered:
            [aStream close];
            [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
            
        default:
            NSLog(@"Unknown event");
    }
}


@end
