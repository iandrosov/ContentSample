/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "RootViewController.h"

#import "SFRestAPI.h"
#import "SFRestRequest.h"

#import "AMFileDownloader.h"
#import "AMFileDownloaderDelegate.h"
#import "MBProgressHUD.h"

@implementation RootViewController

@synthesize dataRows;

#pragma mark Misc

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    self.dataRows = nil;
    [super dealloc];
}


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Mobile SDK Sample App";
    
    //Here we use a query that should work on either Force.com or Database.com
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:@"SELECT Name FROM User LIMIT 10"];    
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    NSArray *records = [jsonResponse objectForKey:@"records"];
    NSLog(@"request:didLoadResponse: #records: %d", records.count);
    self.dataRows = records;
    [self.tableView reloadData];
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataRows count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   static NSString *CellIdentifier = @"CellIdentifier";

   // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];

    }
	//if you want to add an image to your cell, here's how
	UIImage *image = [UIImage imageNamed:@"icon.png"];
	cell.imageView.image = image;

	// Configure the cell to show the data.
	NSDictionary *obj = [dataRows objectAtIndex:indexPath.row];
	cell.textLabel.text =  [obj objectForKey:@"Name"];

	//this adds the arrow to the right hand side.
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // UIAlertView *messageAlert = [[UIAlertView alloc]
     //                            initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display Alert Message
   // [messageAlert show];
    
    
    // Mobile Docs ORG URLS TEST SAME result no AUTH
    // NSString *url = @"https://c.na9.content.force.com/sfc/servlet.shepherd/version/download/068E0000000aRzO";
    //NSString *url = @"https://na9.salesforce.com/sfc/servlet.shepherd/version/download/069L0000000IMZc";

    // AJG URL
    //NSString *url = @"https://cs8.salesforce.com/sfc/servlet.shepherd/version/download/068L0000000IM8o";
    NSString *url = @"https://c.cs8.content.force.com/sfc/servlet.shepherd/version/download/068L0000000IM8j?asPdf=false&operationContext=CHATTER";
    //NSString *url = @"https://c.cs8.content.force.com/sfc/servlet.shepherd/version/download/068L0000000IM8o";
    
    
    // Url for photo - OK
    //NSString *url = @"https://c.cs8.content.force.com/profilephoto/005/T";
    //NSString *url = @"https://c.cs8.content.force.com/profilephoto/729L0000000CcX2/T";
    
    
    // URL Attachments - NOT Working same as Content return script HTML
    //NSString *url = @"https://c.cs8.content.force.com/servlet/servlet.FileDownload?file=00PL0000000KOi7";
    
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLCacheStorageAllowed
                                                       timeoutInterval:600];
    
    // Get credential info access Token here
    SFOAuthCredentials *cred = [[[SFRestAPI sharedInstance] coordinator] credentials];
    // Print to validate we got token data
    NSString *test = [[[[SFRestAPI sharedInstance] coordinator] credentials] accessToken];
    NSLog(@"Access: %@  OBJ: %@", test, cred.accessToken);
    NSURL *test_url = [[[[SFRestAPI sharedInstance] coordinator] credentials] instanceUrl];
    NSLog(@"SF URL: %@", test_url);
    

    NSString* oauthHeader = [NSString stringWithFormat:@"OAuth %@", cred.accessToken];
    //NSString* oauthHeader = [NSString stringWithFormat:@"Bearer %@", cred.accessToken]; // Bearer
    [request addValue:oauthHeader forHTTPHeaderField:@"Authorization"];

    //[request addValue:@"application/pdf" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:oauthHeader forHTTPHeaderField:@"Authorization"];
    //[request setValue:@"application/pdf" forHTTPHeaderField:@"Content-Type"];
    
    /*
    NSArray *arr = request.allHTTPHeaderFields.allValues;
    for (int i=0; i<[arr count]; i++){
        NSString *lib = [arr objectAtIndex:i];
        NSLog(@"Request auth: %@", lib);
    }
    */
    
    //}
    
    NSURL* destUrl = [self localFileForFileId:@"test_mv.png"];
    
    AMFileDownloader* fd = [[AMFileDownloader alloc] init];
    fd.destFile = destUrl;
    fd.sourceUrlRequest = request;
    //NSMutableDictionary* contextDict = [NSMutableDictionary dictionaryWithCapacity:2];
    //[contextDict setObject:callbackId forKey:@"callbackId"];
    // NSDictionary* contextDict = [NSDictionary dictionaryWithObjectsAndKeys:callbackId, @"callbackId", [NSNumber numberWithBool:hideProgressOnCompletion] , @"hideProgressOnCompletion", nil];
    // fd.context = contextDict;
    
    [fd downloadWithDelegate:self];

    
}

-(NSURL*)localFileForFileId:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *basePath = [paths objectAtIndex:0]; //([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    // NSString* tempPath = NSTemporaryDirectory();
    NSString* tempFile = [basePath stringByAppendingPathComponent:fileName];
    NSURL* URL = [NSURL fileURLWithPath:tempFile];
    return URL;
    //return [basePath URLByAppendingPathComponent:fileName];
    
}

-(void)fileDownloaded:(AMFileDownloader*)fd {
    NSLog(@"Downloaded");
    if (progressHUD && [[[fd context] objectForKey:@"hideProgressOnCompletion"] boolValue]) {
        [self hideProgressBar];
    }
    
    // return the URL to the downloaded file
    //PluginResult *pluginResult = [PluginResult resultWithStatus:PGCommandStatus_OK messageAsString:[[fd destFile] absoluteString]];
    //[self writeJavascript:[pluginResult toSuccessCallbackString:[[fd context] objectForKey:@"callbackId"]]];
    
    [fd setDelegate:nil];
}

-(void)fileDownloadFailedWithError:(NSError*)error fromDownloader:(AMFileDownloader*)fd {
    if (progressHUD) {
        [self hideProgressBar];
    }
    
    //PluginResult *pluginResult = [PluginResult resultWithStatus:PGCommandStatus_ERROR messageAsString:[error localizedDescription]];
    //[self writeJavascript:[pluginResult toErrorCallbackString:[[fd context] objectForKey:@"callbackId"]]];
    
    [fd setDelegate:nil];
}

-(void)fileDownloader:(AMFileDownloader*)fd didReceiveData:(NSData*)data {
    
    NSString* myString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"FiLE: %@", myString);
    
    if (progressHUD) {
        bytesDownloaded += [data length];
        float progress = totalDownloadBytes > 0 ? ((float)bytesDownloaded) / totalDownloadBytes : 0.0;
        
        [progressHUD setProgress:progress];
    }
    
    /*
    NSString *resourceToPath = [[NSString alloc]
                                initWithString:[[[[NSBundle mainBundle] resourcePath]
                                                 stringByDeletingLastPathComponent]
                                                stringByAppendingPathComponent:@"Documents"]];
    
    NSString *filePAth = [resourceToPath stringByAppendingPathComponent:@"test1.pdf"];
    [data writeToFile:filePAth atomically:YES];
    
    // to populate the WebView
    UIWebView *my_web_view = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, 800, 900)];
    
    // Comment temp
    NSURL *url2 = [NSURL fileURLWithPath:filePAth];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url2];
    
    
    
    [my_web_view setUserInteractionEnabled:YES];
    
    // Comment temp
    [my_web_view loadRequest:requestObj];
    
    [self.view addSubview:my_web_view];
    [my_web_view release];
    */
    
}

- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

@end
