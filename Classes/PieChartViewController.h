//
//  PieChartViewController.h
//  GottaFeeling
//
//  Created by Liam Hennessy on 28/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"


@interface PieChartViewController : UIViewController <CPTPieChartDataSource, CPTPieChartDelegate> {
	CPTXYGraph *pieChart;
	UIWebView *_webView;
    CPTGraphHostingView *_graphHostingView;
	NSMutableArray *_chartData;
	NSMutableArray *_chartDataTitles;
}

@property(nonatomic, retain) IBOutlet UIWebView *webView;
@property(nonatomic, retain) NSMutableArray *chartData;
@property(nonatomic, retain) NSMutableArray *chartDataTitles;
@property(nonatomic, retain) IBOutlet CPTGraphHostingView *graphHostingView;

- (void)drawChart;
- (void)redraw;
- (void)createLegend;
@end
