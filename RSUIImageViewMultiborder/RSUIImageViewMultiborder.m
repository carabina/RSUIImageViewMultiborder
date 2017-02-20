//  Copyright (c) 2017 Ratul sharker
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "RSUIImageViewMultiborder.h"
#import "RSUIImageViewMultiborder+PropertyHandler.h"
#import "RSCotentModeHandler.h"


@implementation RSUIImageViewMultiborder
@synthesize isRounded = _isRounded;

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    /**
     *  This code segment may confuse you but here is the explanation. We
     *  set the isRounded property before the view is properly layoutted.
     *  so settings it's corner radius before-hand layout sets it wrong
     *  value. so after a layout is done we re-apply the isRounded
     *  value, so that proper corner radius is set.
     */
    self.isRounded = _isRounded;
}
    
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //  drawing image
    [self handleImageDrawing];
    
    //  drawing border
    [self handleBorderDrawing:ctx];
}

#pragma mark setMethod
-(BOOL)isRounded
{
    return self.isRounded;
}
-(void)setIsRounded:(BOOL)isRounded
{
    _isRounded = isRounded;
    if(_isRounded)
    {
        self.layer.cornerRadius = CGRectGetMidX(self.bounds);
        self.clipsToBounds = YES;
    }
    else
    {
        self.layer.cornerRadius = 0.0;
    }
}

#pragma mark drawing related methods
/**
 *  This method manage all image drawing related task. 
 *  It actually generate the image according to the 
 *  self.contentMode, then draw the image according to
 *  the inset created by the border.
 */
-(void)handleImageDrawing
{
    CGFloat imageInset = 0;
    for(NSString *borderWidthPropertyName in [self.class getBorderWidthPropertyNames])
    {
        imageInset += [[self valueForKey:borderWidthPropertyName] doubleValue];
    }
    
    //
    //  get image based on contentMode
    //
    CGRect imageRect = CGRectInset(self.bounds,
                                   imageInset,
                                   imageInset);
    
    
    UIImage *resizedImage = [RSCotentModeHandler getImageForUIImage:self.image
                                                        contentMode:self.contentMode
                                                            forRect:CGRectMake(0,
                                                                               0,
                                                                               CGRectGetWidth(imageRect),
                                                                               CGRectGetHeight(imageRect))];
    [resizedImage drawInRect:imageRect];
}
/**
 *  This method manage all the border drawing related task.
 *  It actually set the current stroke color according to the
 *  currently drawing border, calculate the rect where the
 *  border will be drawn and then draw the border by taking the
 *  consideration of property "isRounded". An elipse is been drawn on
 *  rounded case and an rect is drawn on non-rounded case.
 */
-(void)handleBorderDrawing:(CGContextRef)ctx
{
    NSAssert([self.class getBorderColorPropertyNames].count == [self.class getBorderWidthPropertyNames].count, @"inequal number of border-color and border-width property");
    
    CGFloat summedBorderWidth = 0, currentBorderWidth;
    NSArray <NSString*>  *borderColors = [self.class getBorderColorPropertyNames];
    NSArray <NSString*>  *borderWidths = [self.class getBorderWidthPropertyNames];
    
    for(unsigned int index = 0; index < borderColors.count; index++)
    {
        UIColor *borderColor = [self valueForKey:borderColors[index]];
        currentBorderWidth = [[self valueForKey:borderWidths[index]] doubleValue];
        
        if(!currentBorderWidth) continue;//if border is equal to zero, just ignore the drawing
        
        CGContextSetStrokeColorWithColor(ctx, borderColor.CGColor);
        CGContextSetLineWidth(ctx, currentBorderWidth);
        
        CGFloat size = summedBorderWidth + currentBorderWidth /2.0;
        
        if(_isRounded)
            CGContextAddEllipseInRect(ctx, CGRectInset(self.bounds,size,size));
        else
            CGContextAddRect(ctx, CGRectInset(self.bounds,size,size));

        //
        //  upcoming feature
        //
        //            CGFloat ra[] = {2 , 2};
        //            CGContextSetLineDash(ctx, 0, ra, 2);
        //            CGContextSetLineCap(ctx, kCGLineCapRound);
        summedBorderWidth += currentBorderWidth;        
        CGContextStrokePath(ctx);
    }
}

@end
