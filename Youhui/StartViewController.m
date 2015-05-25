//
//  StartViewController.m
//  Youhui
//
//  Created by xujunwu on 15/2/24.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "StartViewController.h"
#import "AppDelegate.h"
#import "CityEntity.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView* img=[[UIImageView alloc]initWithFrame:self.view.bounds];
    [img setImage:[UIImage imageNamed:@"start"]];
    [img setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:img];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)initData
{
    [CityEntity MR_deleteAllMatchingPredicate:[NSPredicate predicateWithValue:YES]];
    
    self.networkEngine=[[HNetworkEngine alloc] initWithHostName:nil customHeaderFields:nil];
    NSString *url = [NSString stringWithFormat:@"%@city",kHttpUrl];
    NSMutableDictionary* params=[NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"0",@"status", nil]];
    DLog(@"%@",params);
    [self.networkEngine postOperationWithURLString:url params:params success:^(MKNetworkOperation *completedOperation, id result) {
        NSDictionary* rs=(NSDictionary*)result;
        NSArray * arr=[rs objectForKey:@"root"];
        for (NSDictionary *dic in arr) {
            NSString* code=[dic objectForKey:@"areaCode"];
            NSArray *ds=[CityEntity MR_findByAttribute:@"code" withValue:code];
            if ([ds count]>0) {
                DLog(@"%d",[ds count]);
            }else
            {
                CityEntity *entity=[CityEntity MR_createEntity];
                [entity setCode:[dic objectForKey:@"areaCode"]];
                [entity setTitle:[dic objectForKey:@"cityName"]];
                DLog(@"%@  %@",entity.code,entity.title);
            }
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
                if (contextDidSave) {
                    DLog(@"%d",contextDidSave);
                }
                
            }];
        }
        
        [ApplicationDelegate openMainView];
    } error:^(NSError *error) {
        DLog(@"post deviceToken fail");
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
