//
//  PieChartViewController.m
//  GottaFeeling
//
//  Created by Liam Hennessy on 28/11/2010.
//  Copyright 2010 Peer Assembly. All rights reserved.
//

#import "PieChartViewController.h"
#import "FeelingInfo.h"


@implementation PieChartViewController

@synthesize webView             = _webView;
@synthesize graphHostingView    = _graphHostingView;
@synthesize chartData           = _chartData;
@synthesize chartDataTitles     = _chartDataTitles;

#pragma mark -
#pragma mark Plot Data Source Methods
-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    NSString *feeling = [self.chartDataTitles objectAtIndex:index];
    FeelingInfo *feelingInfo = [FeelingInfo feelingForName:feeling];
    return [CPTFill fillWithColor:[CPTColor colorWithCGColor:feelingInfo.color.CGColor]];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [self.chartData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index  {
	if ( index >= [self.chartData count] ) {
        return nil;
	}
    
	if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
		return [self.chartData objectAtIndex:index];
	} else {
		return [NSNumber numberWithInt:index];
	}
}

- (void)redraw {
    [self createLegend];
    if ([self.chartData count]==0) {
        self.graphHostingView.hidden=YES;
    } else {
        self.graphHostingView.hidden=NO;
        [pieChart reloadData];
    }

}

- (void)drawChart {
    pieChart = [[CPTXYGraph alloc] initWithFrame:CGRectMake(0, 0, 170, 180)];
	
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [pieChart applyTheme:theme];
	CPTGraphHostingView *hostingView = self.graphHostingView;
    hostingView.hostedGraph = pieChart;
    
    pieChart.plotAreaFrame.borderLineStyle = nil;
    
    pieChart.paddingLeft = 0.0;
	pieChart.paddingTop = 0.0;
	pieChart.paddingRight = 0.0;
	pieChart.paddingBottom = 0.0;
	pieChart.outerBorderPath = nil;
	pieChart.axisSet = nil;
	
    
	pieChart.borderLineStyle = nil;
    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.plotArea.borderLineStyle = nil;
    piePlot.dataSource = self;
	piePlot.pieRadius = 80.0;
	piePlot.startAngle = M_PI_4;
	piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
	piePlot.centerAnchor = CGPointMake(0.5, 0.5);
	piePlot.delegate = self;
    [pieChart addPlot:piePlot];
    [piePlot release];
    
    [self createLegend];
}

-(void) createLegend {
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"feelingOrderedList" ofType:@"html"];
    NSString *html = [[[NSString alloc] initWithContentsOfFile:templatePath usedEncoding:NULL error:NULL] autorelease];
        
    NSMutableString *list = [[NSMutableString alloc] init];
    int total = 0;
    for (NSNumber *number in self.chartData) {
        total += [number intValue];
    }
    
    // Sort legend to put most popular first
    NSMutableArray *legends = [NSMutableArray array];
    for (int i=0;i<[self.chartDataTitles count];i++) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                             [self.chartDataTitles objectAtIndex:i], @"name", 
                             [self.chartData objectAtIndex:i], @"percent",
                             nil];
        [legends addObject:dict];
    }
    NSSortDescriptor *nameSorter = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSSortDescriptor *sizeSorter = [[[NSSortDescriptor alloc] initWithKey:@"percent" ascending:NO] autorelease];
    [legends sortUsingDescriptors:[NSArray arrayWithObjects:sizeSorter, nameSorter, nil]];

    for (NSDictionary *key in legends) {
        NSString *feeling = [key objectForKey:@"name"];
        FeelingInfo *feelingInfo = [FeelingInfo feelingForName:feeling];
        
        NSString *swatch = [NSString stringWithFormat:@"<span style=\"background-color: %@;\">&nbsp;&nbsp;&nbsp;</span>", feelingInfo.webColor];
        NSNumber *count = [key objectForKey:@"percent"];
        int percent = round(([count doubleValue]*100)/total);
        [list appendFormat:@"<li>%@ %@<span class=\"percent\"> %d&#37;</span></li>",swatch,NSLocalizedString(feeling, nil),percent];        
    }

    html = [html stringByReplacingOccurrencesOfString:@"[[[list]]]" withString:list];
    [list release];
    [self.webView loadHTMLString:html baseURL:nil];   
}

- (void)viewWillAppear:(BOOL)animated {
    [self drawChart];
    
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [_webView release];
    [_graphHostingView release];
    [_chartData release];
    [_chartDataTitles release];
    [super dealloc];
}


@end
