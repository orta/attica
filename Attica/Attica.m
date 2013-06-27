//
//  Attica.m
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

#import "Attica.h"

@interface Attica(){}
@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation Attica

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    });
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        self.bundle = bundle;
        [self createMenuItem];
    }
    return self;
}

#pragma mark - Private

- (void)createMenuItem {
    NSMenuItem *windowMenuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    NSMenuItem *atticaMenuItem = [[NSMenuItem alloc] initWithTitle:@"Snippet Editor"
                                                               action:@selector(openEditorWindow)
                                                        keyEquivalent:@"8"];
    atticaMenuItem.keyEquivalentModifierMask = NSCommandKeyMask | NSShiftKeyMask;
    atticaMenuItem.target = self;
    [windowMenuItem.submenu insertItem:atticaMenuItem
                               atIndex:[windowMenuItem.submenu indexOfItemWithTitle:@"Organizer"] + 1];
}

- (void) openEditorWindow {
    if (!self.windowController)
        self.windowController = [[ATCWindowController alloc] initWithBundle:self.bundle];

    [[self.windowController window] makeKeyAndOrderFront:self];
}

@end
