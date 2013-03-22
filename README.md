QuickCollections - arrays and dictionaries of images without memory usage in objective-C
========================================================================================

You may be wondering if you can use a cache of images without spending too much system memory. The class "QuickImageContainer" 
has this target. It simply works as follows: UIImage-> Array of unsigned integers -> UIImage. But "QuickImageContainer" is thread safe? 
Can i use it in a NSThread method performed in background? The answer is yes. Can I save an image to file and read it it later? 
Yes, of course. "QuickImageContainer" conforms to the NSCoder protocol and another type of serialization. The following is a simple example:

    -(void)viewDidLoad  {
	    [super viewDidLoad];
		
		UIImage *myImage = [UIImage imageNamed:@"myImage.png"];
		QuickImageContainer *c = [[QuickImageContainer alloc] init];
		
		[c setImage:myImage];   // now c holds an array of unsigned integers
		
		myImage = [c imageInContainer];  // get back the image
		
		UIImageView *v = [[UIImageView alloc] initWithImage:myImage];
		[self.view addSubview:v];
		[v release];
		
		[c release];
	}

Archives and Serializations
---------------------------

Assuming that you want to save a "QuickImageContainer" file, you can do it as follows:

    -(void)viewDidLoad  {
	    [super viewDidLoad];
		
		UIImage *myImage = [UIImage imageNamed:@"myImage.png"];
		QuickImageContainer *container = [[QuickImageContainer alloc] init];
		
		[container setImage:myImage];
           [container compress];   // now container holds an array of unsigned integers
		
		NSString* container_path = [[self documentPath] stringByAppendingPathComponent:@"data"];
		[container saveToFile:container_path];
		
		[container release];
		container = nil;
		
		QuickImageContainer *container_2 = [[QuickImageContainer alloc] init];
		[container_2 loadFromFile:container_path];
		
		myImage = [container_2 imageInContainer];  // get back the image
		
		UIImageView *v = [[UIImageView alloc] initWithImage:myImage];
		[self.view addSubview:v];
		[v release];
		
		[container_2 release];
	}
	
	-(NSString *)documentPath  {
	    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		return [paths objectAtIndex:0];
	}
	
By this way you have stored only 10-20 bytes to file, much less than 1 KB. However, you can take advantage
 of NSKeyedArchiver / NSKeyedUnarchiver to save to a file and get back a QuickImageContainer object:

    -(void)viewDidLoad  {
	    [super viewDidLoad];
		
		UIImage *myImage = [UIImage imageNamed:@"myImage.png"];
		QuickImageContainer *container = [[QuickImageContainer alloc] init];
		
		[container setImage:myImage];
           [container compress];   // now container holds an array of unsigned integers		

		NSString* container_path = [[self documentPath] stringByAppendingPathComponent:@"data.bin"];
		[NSkeyedArchiever archiveRootObject:container toFile:container_path];
		
		[container release];
		container = nil;
		
		QuickImageContainer *container_2 = [NSKeyedUnarchiver unarchiveObjectWithFile:container_path];
		myImage = [container_2 imageInContainer];  // get back the image
		
		UIImageView *v = [[UIImageView alloc] initWithImage:myImage];
		[self.view addSubview:v];
		[v release];
	}

NSSharedCollection - a thread-safe dictionary where you can add multiple images simultaneously
------------------------------------------------------------------------------------------------------

 NSSharedCollection is a simple class that makes use of a NSDictionary object accessible from any NSThead,
 using some NSOperation objects to obtain the values. In fact, you can put multiple images simultaneously (it stores a "QuickImageContainer" 
 object in NSDictionary). Here's an example:
 
     -(void)viewDidLoad  {
	    [super viewDidLoad];
		
		[NSThread detachNewThreadSelector:@selector(saveImages) toTarget:self withObject:nil];
		//.....
	}
	
	-(void) saveImages  {
	    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	    NSSharedCollection *collection = [[[NSSharedCollection alloc] init] autorelease];
	    UIImage *myImage = [UIImage imageNamed:@"myImage.png"];
		for(int i = 0; i < 100; ++i)  {  // 100 is a random number
		    [collection setImageInBackground:myImage ForKey:[NSNumber numberWithInt:i]];
		}
           [collection endUpInsertingImages];
		[self performSelectorOnMainThread:@selector(addSubviewInMainView) withObject:collection waitUntilDone:YES];
		
		[pool release];
	}
	
	-(void) addSubviewInMainView:(NSSharedCollection *)aCollection  {
           UIImageView *v = [[UIImageView alloc] initWithImage:[aCollection imageForKey:[NSNumber numberWithInt:0]]];
		[self.view addSubview:v];
		[v release];
	}
	
XCode Linker Flags
------------------
Add "libc++.dylib" to your project or add "-lc++" to your LD Flags