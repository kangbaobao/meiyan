//
//  mpegHeader.h
//  meiyan
//
//  Created by kzw on 2020/5/27.
//  Copyright © 2020 康子文. All rights reserved.
//

#ifndef mpegHeader_h
#define mpegHeader_h
struct VIDEOPARM {
    //进度
    float pro;
    //是否停止解码
    bool zhongduan;
};
typedef void(*RGBSWSCALLBACK)(int, int, uint8_t *, int);
typedef void(*VIDEOBLOCK)(void*);
#endif /* mpegHeader_h */
