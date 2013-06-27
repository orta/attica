//
//  ATCSnippetManager.m
//
//  Copyright (c) 2013 Delisa Mason. http://delisa.me
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

#import "ATCSnippetManager.h"

static NSString *SNIPPET_RELATIVE_DIRECTORY = @"Library/Developer/Xcode/UserData/CodeSnippets";
static dispatch_queue_t backgroundQueue = nil;

@implementation ATCSnippetManager

- (id)init {
    self = [super init];
    if (self) {
        [self loadSnippets];
        [NSFileCoordinator addFilePresenter:self];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            backgroundQueue = dispatch_queue_create("me.delisa.Attica.snippet-directory-watcher", DISPATCH_QUEUE_CONCURRENT);
        });
    }
    return self;
}

- (NSURL *)snippetDirectory {
    return [NSURL fileURLWithPathComponents:@[NSHomeDirectory(), SNIPPET_RELATIVE_DIRECTORY]];
}

- (ATCSnippet *)createSnippet {
    // generate UUID
    // generate stub plist
    // write plist to disk
}

- (BOOL)deleteSnippet:(ATCSnippet *)snippet {
    // delete snippet file from disk
}

#pragma mark - NSFilePresenter methods

- (NSURL *)presentedItemURL {
    return [self snippetDirectory];
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return [NSOperationQueue mainQueue];
}

- (void)accommodatePresentedItemDeletionWithCompletionHandler:(void (^)(NSError *))completionHandler {

}

- (void)presentedSubitemDidAppearAtURL:(NSURL *)url {

}

- (void)presentedSubitemDidChangeAtURL:(NSURL *)url {
    
}

- (void)presentedSubitemAtURL:(NSURL *)oldURL didMoveToURL:(NSURL *)newURL {
    
}

#pragma mark - Private

- (void)loadSnippets {
    
}

- (ATCSnippet *)snippetByUUID:(NSString *) snippetIdentifier {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:snippetIdentifier];

    for (ATCSnippet *snippet in self.snippets) {
        if ([snippet.uuid isEqual:uuid]) {
            return snippet;
        }
    }
    return nil;
}

@end
