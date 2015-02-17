ECDataCache
===========

A generic NSData cache for storing data to disk, which is backed by NSCache for in-memory data.

Usage
-----

Just include the header somewhere up top:

```objc
#import "ECDataCache.h"
```

Then use it in your code like so:

```objc
NSData *someData = [ECDataCache.sharedCache dataForKey:@"some key"];
if (someData) {
    // Do stuff with someData
} else {
    // someData doesn't exist
}
```

You can also use it with URLs to store and load images. For example:

```objc
NSURL *url = [NSURL URLWithString:@"http://www.educreations.com/static/images/logo/logo-large-dark.png"];
NSData *data = [ECDataCache.sharedCache dataForURL:url];
if (data) {
    // We are good to go
    UIImage *image = [UIImage imageWithData:data];
} else {
    // Fetch the url
    ...

    // On successful fetch, store the image to disk
    [ECDataCache.sharedCache setData:data forURL:url];
}
```

License
-------

Uses the [MIT][mit] license.



[mit]: http://opensource.org/licenses/MIT
