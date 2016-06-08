//
//  drawView.m
//  画画
//
//  Created by qianfeng on 15/10/5.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "drawView.h"

@interface drawView ()
{
    UIImage * _images;
}

//每次触摸结束前经过的点，用来形成连线
@property(nonatomic,strong)NSMutableArray * pointArray;

//每次触摸结束的线束组
@property(nonatomic,strong) NSMutableArray * lineArray;

//保存之前画的线条的颜色，宽度，透明度
@property(nonatomic,strong)NSMutableArray * colorArray;
@property(nonatomic,strong)NSMutableArray * widthArray;
@property(nonatomic,strong)NSMutableArray * arfArray;

//保存之前被移除的线条,颜色,宽度，透明度
@property(nonatomic,strong)NSMutableArray * deleLineArray;
@property(nonatomic,strong)NSMutableArray * deleColorArray;
@property(nonatomic,strong)NSMutableArray * deleWidthArray;
@property(nonatomic,strong)NSMutableArray * deleArfArray;

@end

@implementation drawView

//初始化
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _pointArray = [[NSMutableArray alloc] init];
        
        _lineArray = [[NSMutableArray alloc] init];
        _colorArray = [[NSMutableArray alloc] init];
        _widthArray = [[NSMutableArray alloc] init];
        _arfArray = [[NSMutableArray alloc] init];

        _deleLineArray = [[NSMutableArray alloc] init];
        _deleColorArray = [[NSMutableArray alloc] init];
        _deleWidthArray = [[NSMutableArray alloc] init];
        _deleArfArray = [[NSMutableArray alloc] init];
        
        _lineColor = [UIColor greenColor];
        _lineWidth = @10;
        _lineArf = 1;
    }return self;
}
//保存自己之前画的线条
-(void)addLA
{
    NSNumber * arf = [NSNumber numberWithFloat:self.lineArf];
    [self.arfArray addObject:arf];
    [self.colorArray addObject:self.lineColor];
    [self.widthArray addObject:self.lineWidth];
    [self.lineArray addObject:self.pointArray];
    
    //清空之前的点
    self.pointArray = [[NSMutableArray alloc] init];
}
-(void)drawRect:(CGRect)rect
{       
    // 获取当前绘图的上下文(context)
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 10.0f);
    //线条拐角样式，设置为平滑
    CGContextSetLineJoin(context,kCGLineJoinRound);
    //线条开始样式,线帽，设置为平滑
    CGContextSetLineCap(context, kCGLineCapRound);
    
    //查看lineArray数组里是否有线条，有就将之前画的重绘，没有只画当前线条
    if ([self.lineArray count] > 0) {
        for (int i = 0 ; i < [self.lineArray count]; i++) {
            NSArray * array = [NSArray arrayWithArray:[self.lineArray objectAtIndex:i]];
            if (array.count > 0) {
                CGContextBeginPath(context);
                CGPoint  myStartPoint = CGPointFromString([array objectAtIndex:0]);
                
                // 把画笔移动到指定的点
                CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
                for (int j = 1; j < [array count] ; j++)
                {
                    CGPoint  myEndPoint = CGPointFromString([array objectAtIndex:j]);
                       // 从当前的点画一条直线到指定的点
                    CGContextAddLineToPoint(context, myEndPoint.x, myEndPoint.y);
                }
                UIColor * lineColor = self.colorArray[i];
                NSNumber * lineWidth =self.widthArray[i];
                NSNumber *   lineArf =[self.arfArray objectAtIndex:i];
                
                //设置透明度
                CGContextSetAlpha(context, [lineArf floatValue]);
                //设置画笔的颜色
                CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
                // 设置线的宽度
                CGContextSetLineWidth(context, [lineWidth floatValue]);
                // 开始画线
                CGContextStrokePath(context);
            }
        }
    }
    
    //画当前的线
    if (self.pointArray.count > 0) {
        
        CGContextBeginPath(context);
        CGPoint myStartPoint = CGPointFromString([self.pointArray objectAtIndex:0]);
        CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
        for (int n = 1 ; n < [self.pointArray count]; n++)
        {
            CGPoint myEndPoint = CGPointFromString([self.pointArray objectAtIndex:n]);
            CGContextAddLineToPoint(context, myEndPoint.x, myEndPoint.y);
        }
            CGContextSetStrokeColorWithColor(context,self.lineColor.CGColor);
    
            CGContextSetLineWidth(context, [self.lineWidth floatValue]);
        
            CGContextSetAlpha(context, self.lineArf);
            
            CGContextStrokePath(context);
        }
    }

//画笔触摸的所有的点
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch=[touches anyObject];
    //取出每一个点
    CGPoint  myBeginPoint=[touch locationInView:self];
    
    NSString * spoint=NSStringFromCGPoint(myBeginPoint);
    [self.pointArray addObject:spoint];
    [self setNeedsDisplay];
    
    //动画
    //<1>获取手指点击屏幕位置的坐标
    
    CGPoint point = [touch locationInView:self];
    
    //<2>在点的周边设置一个层
    CALayer * waveLayer = [CALayer layer];
    
    //<3>设置层的显示位置
    waveLayer.frame = CGRectMake(point.x - 1, point.y - 1, 10, 10);
    
    //<4>设置层的边框颜色
    
    waveLayer.borderColor = [self.lineColor CGColor];
    
        //<5>设置layer的边框宽度
    waveLayer.borderWidth = 0.3;
    //<6>设置layer的圆角效果
    waveLayer.cornerRadius = 5;
    //<7>将layer添加到当前视图的层上
    [self.layer addSublayer:waveLayer];
    
    //<8>让圈等比例增大
    [self changeLayer:waveLayer];

}

-(void)changeLayer:(CALayer *)layer
{
    //<9>设置layer大小的边界值
    const int maxScale = 2;
    //<10>当层扩大到120倍的时候就让它从界面消失
    if(layer.transform.m11 < maxScale)
    {
        [layer setTransform:CATransform3DScale(layer.transform, 1.1, 1.1, 1.0)];
        [self performSelector:_cmd withObject:layer afterDelay:0.05];
        
        //performSelector:用于方法的调用
        //递归调用自身方法 让layer逐渐变大
        //_cmd表示调用自身方法名称
    }
    else
    {
        [layer removeFromSuperlayer];
    }
}

//触摸结束
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self addLA];
   // _pointArray = [[NSMutableArray alloc] init];
}
//清除所有
-(void)cleanAll
{
    
    [self.lineArray  removeAllObjects];
    [self.colorArray removeAllObjects];
    [self.widthArray removeAllObjects];
    [self.arfArray  removeAllObjects];
    
    [self.deleLineArray  removeAllObjects];
    [self.deleColorArray removeAllObjects];
    [self.deleArfArray  removeAllObjects];
    [self.deleWidthArray  removeAllObjects];
    
    [self setNeedsDisplay];
    
}

//返回上一步
-(void)backStep
{
    if(self.lineArray.count > 0){
    [self.deleLineArray addObject:[self.lineArray lastObject]];
    [self.deleWidthArray addObject:[self.widthArray lastObject]];
    [self.deleColorArray  addObject:[self.colorArray lastObject]];
    [self.deleArfArray  addObject:[self.arfArray  lastObject]];
    
    [self.lineArray removeLastObject];
    [self.widthArray removeLastObject];
    [self.colorArray removeLastObject];
    [self.arfArray removeLastObject];

    [self setNeedsDisplay];}
    
    if (self.lineArray.count == 0) {
    //self.layer.contents=(id)_images.CGImage;
        }
}
//返回下一步
-(void)nextStep
{
    if (self.deleLineArray.count > 0) {
        
        [self.lineArray addObject:[self.deleLineArray lastObject]];
        [self.widthArray addObject:[self.deleWidthArray lastObject]];
        [self.colorArray addObject:[self.deleColorArray lastObject]];
        [self.arfArray  addObject:[self.deleArfArray lastObject]];
        
        [self.deleLineArray removeLastObject];
        [self.deleColorArray removeLastObject];
        [self.deleArfArray removeLastObject];
        [self.deleWidthArray removeLastObject];
        
        [self setNeedsDisplay];
    
    }
    
}





@end
