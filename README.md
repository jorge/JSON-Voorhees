JSON-Voorhees
=============

Lightweight Objective-C category for parsing JSON into NSManagedObjects

####Usage

Meant to be used with AFNetworking + CoreData. This is not a fully generalized solution. Yet. 

####Example

	- (void)getFromServer:(void(^)(NSDictionary *))completion error:(void(^)(void))onError {
	 	 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/v1/	route.json", API_URL]];
	 	 NSURLRequest *requset = [NSURLRequest requestWithURL:url];
	  	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requset success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
	   	 completion(JSON);
	  	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
	 	   onError();
	  	}];
	  	dispatch_async([APIController sharedQueue], ^{
	   	 [operation start];
	  	});
  
	}
	
	
	[self getFromServer:^(NSDictionary *completion){
    NSArray *contents = [NSObject parseArray:json
                            	   keyMapping:[Model attributeMapping]
                                    forClass:NSStringFromClass([Model class])
                      inManagedObjectContext:<NSManagedObjectContext>
                               forUniqueKeys:[Model uniqueKeys]];

	FT_SAVE_MOC(delegate.context);
    [self.tableView reloadData];
    
    onError:^{
	    //handle the error
    }
  		
  	
