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
    
    self.userLogin = @{@"testuser1":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyOTQ3NDg2NCwibmJmIjoxNTI5NDc0ODY0LCJleHAiOjE1Mjk1MDQ4OTQsImp0aSI6MTUyOTQ3NDg5NDg5NSwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjEifQ.uYlKHfvz7xzAKUW56ssAeo9F5CcuwqcsB8D_KZ5XMzeX19gEwT6tXNh8YVxEzHNHHdtYo8jE1wfWSgbMQwfTFp6OZUOEJ1MtQSzmA6VXa40wIwFDrX1v2ytfoaPqP8IN5gGBzx4LBZclgsJvGw1dDbZOJajL6kdnOzFgkkmjWeJLc0sYxF9ghlDtRfN3x0KPLE87Z1EeG_vOti7iA7b5-wGoG7kINHblD4FWUXYonnf8bANximy5kxQw8SjfnPWkHtME4PFShean1rR_choCNQlip7d2YH4g6iIYgFef3menAXAjh3h2ULQ0xAjTacJbZEFdtf5n2-ipBcuA5zUZxQ",
    @"testuser2":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyOTQ3NDkwNCwibmJmIjoxNTI5NDc0OTA0LCJleHAiOjE1Mjk1MDQ5MzQsImp0aSI6MTUyOTQ3NDkzNDI0OSwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjIifQ.EIjY_0HkhCvzx_KqGRqJEU4kBUSjQ-tA9GUe59rltfrxGOLYl8DVP3McS0T04own1PJuvu7As8wx8aitgMcTfyYZu-hp_OxjcULamMUuaxKkybWrr_ezZEokUA_lUcfbrcgdvU27-wKN9ZoPxS6th9QIqffKvpgUoLrdSp-Yg-7XJNTlg7odeMMkR416Iektv3jeVYpAURBPN6HqMHJrUTmDIgwwyatWB6kdUZjrg4iIo56CUKN0Sr7D60HV1GR-N3tCWcn2bgjg80X35xE_1iB_yRgZCYno7WmGXgzPVs7vFj2e3_QcMXyV5q9UoCAnpFqrYc2YhB9CTZey3IhsQg",
                       
    @"testuser3":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUzMTI5MTU5MiwibmJmIjoxNTMxMjkxNTkyLCJleHAiOjE1MzEzMjE2MjIsImp0aSI6MTUzMTI5MTYyMjYzNywiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjMifQ.pYE1QZTE6CL7eJPiUulNal4BRSDcfC87eGqAuezhsjgyrUjt7gu63lBtodj8BWf5LCVS222216brAOyDIggiMJ_kG3VXpa402IWxFItDcHKKo_XUkO2d9nMMRG6ZK6wwCDhmvKvMQ6r_7ErhoZstgZ-922yzrd7EHCox6BvSZfiTy3NWIJLx3n6Wy99E2S_6gu6gA4CltZWXc4WAbImxsyD6JQZb1NwF_LAsHAZT0WAPw0Z2tMtRMIRwOuGay54OWBom4A1lBQXtfl1VOu1e62pJG4Cj7UlUypCXU69zhOrNMs7AQ7AZSowCLcLMrDn_IWVGb3BVoHzDr2nRMGtJmg",
                       
    @"testuser4":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyOTQ3NDk0OSwibmJmIjoxNTI5NDc0OTQ5LCJleHAiOjE1Mjk1MDQ5NzksImp0aSI6MTUyOTQ3NDk3OTQxNSwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjQifQ.k1RtUyCbyNDD1gi-HrSpPxZBtGidURWFDCWDDe1D5TKASXa7a7YbqAt6s_aulyXEBLF3i4QBMW6Hxbj9TUBk49gU2TrUZ5RaBnLc2VvtIH7Gc6RhMbQTKS7XoLE6z_Fz_a9KMBuIf1uwzOFpXHAtNtIOyiZmmmmw-CXhPrxCJ2MExTFWg7tBWPSqUiGjzz2TXsaIq0qhpnpn0oBA203d2Vl2-f7UBZqt6_0qtvanGKy-tB5WF_xVzqjUDjnTOO3hk0x-HprRSlurE5842RLTG_6i935SyKB1hRK-07Pwgzbpbi43jEPYneyLoACNoZGEwlc1FyCIRbIIPSLZkdr54w",
                       
    @"testuser5":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyOTQ3NDk3MCwibmJmIjoxNTI5NDc0OTcwLCJleHAiOjE1Mjk1MDUwMDAsImp0aSI6MTUyOTQ3NTAwMDMxMywiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjUifQ.FwVGnB3vgX_kzTGzkrc2TdMoRy0qXDYO5QY2DwWg4HHexmApuq0mBzvIumdBIvC0mAIEiGaUgSmZYYu1MrVtOLtZ-Gg-YteOT03SiAwQjupAs8LmwQ-_304H0IQWWlxztJmfdFsDaBcArsnrGjvunawAY8cw4uSbDCJ2VfnLehpdd9OZjZPZkxgqxnKCuB6N4YC5Y1VqqCxpopBJeVAq0vPespA3rYHa6OLR3WHaiTYuEvukmA3OumoowET5xrfwFVR3Q3GJokpRLfTVHrOIDTej4cbRE3qJ8ZShbHvl6NHcqdsgBo5f2xAoiDkrPUdT3qzgKIzT_opyma4krILkmQ",
                       
    @"testuser6":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyOTQ3NDk5NCwibmJmIjoxNTI5NDc0OTk0LCJleHAiOjE1Mjk1MDUwMjQsImp0aSI6MTUyOTQ3NTAyNDgxMywiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjYifQ.rBUiCAffYolb3fVuzOXXVVUFBg1GkZZric3jGdhA5G5OrbLT6jqP19Ejj2RnB3gE0db4h71GMTSgLFTHV4yUo-UJQIYqUEcE2yAgneSGhOfD-2f99X7voju1Y6iQkGX0uaCU1WdOYwV4DxVIb5ouTerRWh3TxCVXPy_T9FJq9WgptKmyd5qdDbya-Y-KvSYnUwbHvCVQGXmVXk27s4y1FjXyv6dVrdWiwxOkVzm0eD1MaIs7oW7QmIkJhNZyF7yF54PJKsUv8vMfdFWTRlvg0bwmOjLPGnqA7ODdtoc0u0n8AFGSZhAw9EAdRH_AjrRRv4SzCfO9zK2Nh1XGHAxz2Q",
    @"testuser7":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyOTQ3NTAxNSwibmJmIjoxNTI5NDc1MDE1LCJleHAiOjE1Mjk1MDUwNDUsImp0aSI6MTUyOTQ3NTA0NTQyNSwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjcifQ.HnAHujaL0bY5CX0FeWxRklrkL0tpWxQvseydjgYZt6NVM3kH0H2Uug6LrFt4GG5w7idTUzER9efMhazlOhYO3Mo4wqc38Ls6e7iktw5KJ0t60yrS1Gmfg7KKBSNsa8HQ61kyddhDRiZ3DNoZoL49dIkZy5yIsJig4WhMqkOwNgj-ZuR4E1pyChUsACvy23m5f0rje5xwsrJwpWVKmP4cHbpB_sEvp5fPXIiBVytDmOnCYuamK8c9rFvK-7UMCVG_PpnHBWUW2SxYW5N_feK4IwhBj_ttG2Tr18l6SiOUX1KuSwxIHgNCFZse0-Gj-TtaTmGGhpCY3pZZihXqRl8N1g",
                       
    @"testuser8":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyOTQ3NTAzMywibmJmIjoxNTI5NDc1MDMzLCJleHAiOjE1Mjk1MDUwNjMsImp0aSI6MTUyOTQ3NTA2MzQ2NywiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJ0ZXN0dXNlcjgifQ.VUaTF60Vg8ihLdUQERK4yapsItMhqV2j_uqmQfddV8Iad-VyuisZ04MSNc1Z3WO_AD4gLyjGJSQkeYSNTjkpU_zRa0Y-yvZI4WmoMJ6uM0X2px40anQY71aSn4QTK2e_aXuniTtWKhsq0rfcUyRGsH8fXkOjR-zaH3gdXwzcNk0zjeM5pW3YnofHw-eHqu-7S_ze52nVE9Lw_zhLALYQVeKo4VeKtCM6x0YTAGpsXw8GlK7WeNKqhwm9GgCOrNZEA4_uarbZNL2LJn9L9CYai9cN0ibsEFxLI5o02piZB6g7-ziCV-AuKf5QQGIc9cE4HQVM1RuVhWtVRlOgPstZBA",
          
                       @"TheCustomer":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODk2Nzg2OSwibmJmIjoxNTI4OTY3ODY5LCJleHAiOjE1Mjg5OTc4OTksImp0aSI6MTUyODk2Nzg5OTQ4NCwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJUaGVDdXN0b21lciJ9.GA-SwbQoOeHv77wOBF-B6nflFc09oMIqCT_C3L7EntYXZcqc6wLFNIYivGHI8TQ0hue5tFKf06Ybx1Fhk9tBCB3Up9k_HVmxvCPSdx-voDPgiwU80X51ldHae8BBnX1awW5gQhrf3UfpBdBhv32XsX7fpKy5Z4lZTMQqHmozqemeNuJAYdH1tqFEuagtvsxGlhsQDqtyQR7PnW37KxDQ5EUvMJ2M0Qr1OwqelW8lDzmncL8kHnZp22VBaufzZqnM1NQt74rA8S5UIn4SW577hZyImcW408ostOUhJIfiDPBGTUt71BlGeoxygnHTUdH-WxZViVgu1yVRyKy728Z6CA",
                       
                       @"TheTech":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODk2Nzk1NSwibmJmIjoxNTI4OTY3OTU1LCJleHAiOjE1Mjg5OTc5ODUsImp0aSI6MTUyODk2Nzk4NTYyOSwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJUaGVUZWNoIn0.trQDVeZIok_DidN2rzUyrFRm_qPSj2YLOJxYL8pGsXHVdAk_oN119lU9cnKkMkQmLSfIG-YxfF5hNt-M15XEXH1yWmEQtI7WZr_0-owvAvMGu4US2kseiDhqCGydIS3rTnoM8g2D0Hg0CT_EfZg7ZBXj2oRzFmSrrcvfaJpeRhsgQdfRF7XqzqWIjJYf_G4KatkUO-uSSKGVFvI8z4t5_lctmQNMWaS7-0Ih6tDD_mUUoujrWvbnYdiIf2ymjErTi7z6TsqA4ZRrxviMAPT7nkDK8uKR9SGA-qyrxrbkUifHDue0TB1awnk-HgNtC59rB6nHWBb8HlT9piNZCTXK4g",
                       
                       @"TheManager":@"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTUyODk2Nzk5OCwibmJmIjoxNTI4OTY3OTk4LCJleHAiOjE1Mjg5OTgwMjgsImp0aSI6MTUyODk2ODAyODk2NywiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiLyoqIjp7fX19LCJzdWIiOiJUaGVNYW5hZ2VyIn0.xrPVESnkhd438QqkEwoOOnfD776i3kehVAiGengajUj1g8qmR2tHEGekFrL_9YihSTYNLDT1vMEkumjJWfTM01BWgw8OO1nBdPR_0JCWC5_53RBEdrip3_IHjuhn7W0FqoqZMmZFT7nzRcCeS0Z6nyw_ERnE6XeXQop__4QwTX1detkoULWeFUrnWLeH5nfPy4BWdqgkUhlo3-e1xm3F5xMOrALk_2y0_fQYY00HYYUIz8nBODfZbrc35YvnQtXDhMi_oKk4srcjqMw7O_8Uu1-FeqjLuqrR0bgrCxYXFJaOvqLxX-1S3XBT_Wa4YuixHGyZk5lgVv4Lf-0pUJMQtg"
                         };
    

}
- (IBAction)onLoginPressed:(UIButton *)sender {
    AppDelegate *appDelegate = ((AppDelegate *)[UIApplication sharedApplication].delegate);

    NXMConversationCore *stitch = [NXMConversationCore new];
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
