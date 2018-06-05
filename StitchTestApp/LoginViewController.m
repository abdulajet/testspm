//
//  LoginViewController.m
//  StitchTestApp
//
//  Created by Chen Lev on 5/24/18.
//  Copyright © 2018 Vonage. All rights reserved.
//
#import <AVFoundation/AVAudioSession.h>
#import "LoginViewController.h"
#import "ConversationListViewContoller.h"

#import "AppDelegate.h"

@interface LoginViewController()
@property (weak, nonatomic) IBOutlet UITextField *autoTokenField;
@property NSDictionary<NSString *,NSString *> * userLogin;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
    {
        [[AVAudioSession sharedInstance] requestRecordPermission: ^ (BOOL response)
         {
             NSLog(@"iOS 7+: Allow microphone use response: %d", response);
         }];
    }
    
    self.userLogin = @{@"testuser1":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODE4NjAwMSwibmJmIjoxNTI4MTg2MDAxLCJleHAiOjE1MjgyMTYwMzEsImp0aSI6MTUyODE4NjAzMTIwMywiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjEifQ.QD_uvPYm9pItxICctwo65kiomAv53SUGdw_Cf7h_0UXM1Q5-gyG4-4zvxtz-pjgi5OxWJ1PRdK8pnxxIisVEP8E-4zYH4D7_4u-dvA5aCefEMyAHKp8fr2GZli6Bv7mrrUW9iATzFjheXbYuDvYoaBOSIlImwmf4EeW5IDXjFWoZmGfPr7hrv6aCGe6sjvJjBtuTJScjC6SDcS95lkVqX23GKuHaaTZ0unnKDFqgTD5Yy95NZgbdAQqvD_Q6KeqiolHW36ET4vaWgZAycjuwLkUW52zKbphHPBvW-KSyoIuOP588fAjMJ1xbMz8mYO87C-fBBAeu_Wru7zq28uB3hQ",
    @"testuser2":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODE4NjAxMSwibmJmIjoxNTI4MTg2MDExLCJleHAiOjE1MjgyMTYwNDEsImp0aSI6MTUyODE4NjA0MTA4NiwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjIifQ.N-oIcOv8aJCBElyheIFutgTxa6oB8AmF6oS7M0g5TZnMH0cSMWrZowId5iYg7XmpoFhCp5bubl3uavlhQ0xj3IPB7JeBLXb2mTS9HiGtZ1W5sIYy2NoZhyuoLoQptfelr1AASuqhR7bL0uFAJOKvjD9ztIuuk433RNaNLl_9dHOXjWaCeKgdSlN0v6s1oIf2yLAGQu5syCb-hIMoi3wYhDo4VJgQED2syWLyqQUcKEHjnZmNI0W9WgWchc0YmPYmNril2toOAG_UcRTN7BFCH2CGAaJBFap2Fi9s9Q3zIkXNltGchFr2qRjjXyVUmQ7zVf-y0TPyDXxYSRG-kMyULQ",
                       
    @"testuser3":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODE4NjAzNiwibmJmIjoxNTI4MTg2MDM2LCJleHAiOjE1MjgyMTYwNjYsImp0aSI6MTUyODE4NjA2NjY4OSwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjMifQ.U1LRf6WEtYolMCLciE0pRjwFP6w9ATJBOsInat1X3E_7QPbtDsvY43weFmENRZn5Zqz8ZZGUzC76XjzV09s8ftdPuUYjEXi8BEsVGjEPVYZLkZlRRT4qg8Gha4OWJx9L8e88_Gxl76aiyjxxbWnpRiIMHWEc7h9rBc_6q0AOZyw5HfCwQnGQYGQQG-TBNWNh8BVuef4dZhxg7sHKEyrKQxBvyCp3xd4C4IdJbSvnCymNJlLQ3KGFypWT9bpC2g3_yMZ5fyDj4sv0Fuch88Vpy819vcedbuTLXqyXJv4Kv84anaungC1uN5Z3vD1ZkjJ9YXkDCAUVbM0ECDexH3dgwA",
                       
    @"testuser4":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODE4NjA1MiwibmJmIjoxNTI4MTg2MDUyLCJleHAiOjE1MjgyMTYwODIsImp0aSI6MTUyODE4NjA4MjQ2MiwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjQifQ.Q6MpV5DmeA8wgoZAIOp56rzV--QB6eQxh6rEOrQSYK3yr_HUHYpxz6ZkCsn5qOY_NNcETqcgx3M0og8XD2DxCSO1r5C-_i_vu9myhSi23NEN8QmtO9gTI2k3ZXjZbmvki1TsZPD1bCKZ7zxYn9FW3dZgVRioAmcRSrPJs7_QGKcBDhzLUGlhqgVMtq441Jm5t2O7-_2VK3zG1769WWHWepBvU8qHAdNCS2b0D4g3e4dBBwRvudJbRlvZ-wfU6iCTthu_eZYdEPyt1hQYSRUBh8tPrLROYSUQUVGDxzRtct2d3eU98OmgqtsA2PCuF4fMK-qWqjbYWaOKEEX4JPUIbw",
                       
    @"testuser5":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODE4NjA3MywibmJmIjoxNTI4MTg2MDczLCJleHAiOjE1MjgyMTYxMDMsImp0aSI6MTUyODE4NjEwMzA0NywiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjUifQ.V7u3OD8eYgWcD5WRpn-tqtJ28Vd9PAJ7mYWyWP_oEufZvv80SFdjGwRl3FXvY6lLA3TnpjKaRbuAtzT7HRWJ4h0LwxKgififGiS878b97B_XnaK5wXZEXJOYSJL5eWX8JpYGu91jb876BkNpiQ9gTf2nYUTEmOWPUlhTwpoq7VlS5xnmZL4PVrMjBg5keKnytQNgt1l_jACB1NwKuu3UHwyrdhjqgf4SjcLccuVXoeyj_qh_V35dmqG7W9vQAZEGueXfwcxqzOuKy0K9b5EM9IiyQAI9hJDEhEWsieAUdifya4qojapKjwZXNsWmKUcLrkAoEUg_ElQ5Bgp3qJixmg",
                       
    @"testuser6":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODE4NjA5MiwibmJmIjoxNTI4MTg2MDkyLCJleHAiOjE1MjgyMTYxMjIsImp0aSI6MTUyODE4NjEyMjE5MCwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjYifQ.mU_42Skrz9vjBkKbrKGM6lWT0QaSFHFHfhHOosw1_2IIvQPPKlUzfeogJNJFz4MYGS6ynp0aViIo5MwNaJ4Eyp4DC0bi6-ZwihtSCOXNVtesMcOBYUbqvifF3OX_qtiN_tH71sBFlkc7r7XnpNo3Q_-OA-55ybg3KOnGRrcF9vfCI4wdfye5_ie5tfe_fYrDLVOTMEAYGnsMqaonov3FZL4G3jasmt-PKnZZueScH-24bUWsLFg0LOu69MzoZVh78wxGuZRRjT89iWMA0ajMyUyxc7Ll59fpYNj-FFI30bgad9vDwgxbCV2QELeQLAyw4jcbEzAfLbC33gnvHOKQCQ",
    @"testuser7":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODE4NjEwNywibmJmIjoxNTI4MTg2MTA3LCJleHAiOjE1MjgyMTYxMzcsImp0aSI6MTUyODE4NjEzNzQxOCwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjcifQ.Ek_sOLOzarDjtWFaH8XiyZnhTUWvL16QDmJNWZh89KH3IJou1fYoCkwd5fUwxRgrXt5Zcp_-fjxCDd-FinlTHob9uxzmu2MRfM4Zm9gJPvAeL-aN47HOFPtDxWULLCSjz-Zum-ckFynrBuYa1-_fveJ_oyF0Te_0lGQx6qwplVJdPCYMpOnzV884BYRVyU4I3zMQnI_ElRmf39-1QN8MYwNbrQFXWxAPyjsFINxKBcOzskrZl-CB0d8pHWukAoGphtSrnuWzje9Fz0GYz5ZPose-IUqCHTVhRJjzZW9eyzIjAwamspGsIAgeCU8FP7zrO7nfohLsrGNA3ck1pDoUFA",
                       
    @"testuser8":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODE4NjEyMywibmJmIjoxNTI4MTg2MTIzLCJleHAiOjE1MjgyMTYxNTMsImp0aSI6MTUyODE4NjE1MzU0MSwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjgifQ.R983OwSpf4gmUY42A-4Le9BautWesehjAcIbr7hClhtuj2zn2PEYvlCZMa2bLhW6QEbkXrurhTO-vGIGN4YNMr7MJxF3dQx_NuGa8P-L9hiQWWgrkP6SE8qc_fejhyKuBVeN5aZFPyy2W6a96jRSiqzKiONjzfCuPJPSyjgq4vfAVjIf78FzeqShK7p1wlnGfDa-iqpA8KGG_kZc1f8dkkC7EVTOqtWh7H7rpXfmYl7JjXTOHIceEjJRszzmaJTgvkxS5XCVKeP6NnkE4ogy_GtdrnwNnGNeZDAYwnmkVAHVscmpKElL5RARIO-BiqFxd7eTC99UTvAIPH6TB2XP5g"
                         };
    

}
- (IBAction)onLoginPressed:(UIButton *)sender {
    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);

    StitchConversationClientCore *stitch = [StitchConversationClientCore new];
    [appDelegate setStitch:stitch];

    NSString *username = self.autoTokenField.text;
    NSString *token = self.userLogin[username];
    if (!token) {
        return;
    }

    [stitch loginWithAuthToken:token onSuccess:^(NSObject * _Nullable object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showConvertionListVC];
        });
    } onError:^(NSError * _Nullable error) {
        // TODO:
    }];
}

- (void)showConvertionListVC {
    ConversationListViewContoller *conversationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationNav"];
    
    [self presentViewController:conversationVC animated:YES completion:nil];
}


@end
