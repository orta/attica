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
static NSString *SNIPPET_EXTENSION = @"codesnippet";
//static dispatch_queue_t backgroundQueue = nil;

@implementation ATCSnippetManager

- (id)init {
    self = [super init];
    if (self) {
        [self loadSnippets];
        [NSFileCoordinator addFilePresenter:self];
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//            backgroundQueue = dispatch_queue_create("me.delisa.Attica.snippet-directory-watcher", DISPATCH_QUEUE_CONCURRENT);
//        });
    }
    return self;
}

- (NSURL *)snippetDirectory {
    return [NSURL fileURLWithPathComponents:@[NSHomeDirectory(), SNIPPET_RELATIVE_DIRECTORY]];
}

- (ATCSnippet *)createSnippet {
    ATCSnippet *snippet = [[ATCSnippet alloc] init];
    snippet.uuid    = [NSUUID UUID];
    snippet.title   = @"Untitled snippet";
    snippet.fileURL = [NSURL fileURLWithPathComponents:@[[self snippetDirectory].path, [snippet.uuid UUIDString]]];
    return snippet;
}

- (BOOL)deleteSnippet:(ATCSnippet *)snippet {
    NSError *error = nil;

    [[NSFileManager defaultManager] removeItemAtPath:snippet.fileURL.path error:&error];
    if (!error) {
        NSLog(@"Removing snippet %@ if its in list (%d)", snippet, [self.snippets containsObject:snippet]);
        [self.snippets removeObjectIdenticalTo:snippet];
        return YES;
    }
    NSLog(@"Error deleting snippet: %@, %@", error, [error userInfo]);
    return NO;
}

#pragma mark - NSFilePresenter methods

- (NSURL *)presentedItemURL {
    return [self snippetDirectory];
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return [NSOperationQueue mainQueue];
}

- (void)accommodatePresentedSubitemDeletionAtURL:(NSURL *)url completionHandler:(void (^)(NSError *))completionHandler {
    NSLog(@"Deleting snippet at %@", url.path);
    if (![self isSnippetURL:url]) return;

    ATCSnippet *snippet = [self snippetByURL:url];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"me.delisa.Attica.snippet-deletion" object:snippet];
    [self.snippets removeObject:snippet];
    completionHandler(nil);
}

- (void)presentedSubitemDidAppearAtURL:(NSURL *)url {
    if (![self isSnippetURL:url]) return;

    NSLog(@"Adding snippet at %@", url.path);
    ATCSnippet *snippet = [[ATCSnippet alloc] initWithPlistURL:url];
    [self.snippets addObject:snippet];
}

- (void)presentedSubitemDidChangeAtURL:(NSURL *)url {
    if (![self isSnippetURL:url]) return;

    NSLog(@"Updating snippet at %@", url.path);
    ATCSnippet *snippet = [self snippetByURL:url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:url.path];
        if (snippet) {
            [snippet updatePropertiesFromDictionary:plist];
        } else {
            snippet = [[ATCSnippet alloc] initWithPlistURL:url];
            [self.snippets addObject:snippet];
        }
    } else {
        [self.snippets removeObject:snippet];
    }
}

- (void)presentedSubitemAtURL:(NSURL *)oldURL didMoveToURL:(NSURL *)newURL {
    if (![self isSnippetURL:oldURL]) return;

    ATCSnippet *snippet = [self snippetByURL:oldURL];
    snippet.fileURL = newURL;
}

#pragma mark - Private

- (BOOL)isSnippetURL:(NSURL *)url {
    return [[url.path pathExtension] isEqualToString:SNIPPET_EXTENSION];
}

- (void)loadSnippets {
    self.snippets = [NSMutableArray new];
    @try {
        NSString *path = [self snippetDirectory].path;
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        NSString *directoryEntry;

        while (directoryEntry = [enumerator nextObject]) {
            if ([directoryEntry hasSuffix:SNIPPET_EXTENSION]) {
                [self.snippets addObject:[[ATCSnippet alloc] initWithPlistURL:[NSURL fileURLWithPathComponents:@[path, directoryEntry]]]];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception occurred while loading snippets: %@", exception);
    }
    NSLog(@"%ld Snippets Loaded.", (unsigned long)self.snippets.count);
}

- (ATCSnippet *)snippetByURL:(NSURL *)snippetURL {
    for (ATCSnippet *snippet in self.snippets) {
        if ([snippet.fileURL isEqual:snippetURL]) {
            return snippet;
        }
    }
    return nil;
}

@end
