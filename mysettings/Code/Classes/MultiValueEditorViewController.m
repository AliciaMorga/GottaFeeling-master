/*******************************************************************************
 * Copyright (c) 2009 Stephen Darlington.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *    Stephen Darlington - initial API and implementation
 *******************************************************************************/ 

#import "MultiValueEditorViewController.h"


@implementation MultiValueEditorViewController

/* PA: ADDITION START ----------------------------------
 * If there is a caf file which has the same name as the cell value, then play it
 */
- (void) playAudioFile:(NSString *)audioFile {
    [audioPlayer stop];
    [audioPlayer release];
    audioPlayer = nil;
    
    if ((audioFile == nil) || [audioFile isEqualToString:@""])
        return;                                         // Not asked to play anything
    
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:audioFile ofType:@"caf"];
    
    if (path == nil)
        return;                                         // There is no file to play
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    [audioPlayer prepareToPlay];
    if (audioPlayer.duration < 1.5)                       // Repeat small audio samples
        audioPlayer.numberOfLoops = 3 / audioPlayer.duration;
    [audioPlayer play];
}

- (void) dealloc {
    [audioPlayer stop];
    [audioPlayer release];
    [super dealloc];
}

- (void) loadView {
	[super loadView];
	
	// the area below the navigation bar 
	CGRect visibleframe = self.view.frame;
	visibleframe.size.height = visibleframe.size.height - self.navigationController.navigationBar.frame.size.height;
	visibleframe.origin.y = 0;
	
	// setup and add the table view 
	UITableView *tableView = (UITableView*)[self.view viewWithTag:666];
	tableView.frame= visibleframe;
	tableView.scrollEnabled = YES;
}
/* PA: ADDITION END --------------------------------- */

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[cell configuration] objectForKey:@"Titles"] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *MyIdentifier = @"MultiViewCell";
	
	UITableViewCell *ocell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (ocell == nil) {
		ocell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
    
    if ([cell.value isEqual:[[[cell configuration] objectForKey:@"Values"] objectAtIndex:indexPath.row]]) {
        ocell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        ocell.accessoryType = UITableViewCellAccessoryNone;
    }
	ocell.textLabel.text = NSLocalizedStringFromTable([[[cell configuration] objectForKey:@"Titles"] objectAtIndex:indexPath.row],
                                            [cell stringsTable],
                                            nil);
	return ocell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.value = [[[cell configuration] objectForKey:@"Values"] objectAtIndex:indexPath.row];
	for (UITableViewCell* a in [tableView visibleCells]) {
		a.accessoryType = UITableViewCellAccessoryNone;
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UITableViewCell* activeCell = [tableView cellForRowAtIndexPath:indexPath];
	activeCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self playAudioFile:(NSString *)cell.value];
}

@end
