//
//  EmulatorAPI.h
//  GBA4iOS
//
//  Created by r.takanashi on 2020/11/03.
//  Copyright © 2020 Riley Testut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../emu-ex-plus-alpha/GBA.emu/src/vbam/gba/Sound.h"

extern GBASys gGba;

GBASys EmulatorAPIGetGlobalGBA(){
    return gGba;
}

void EmulatorAPISetVolime(float volume){
    soundSetVolume(volume);
    soundReset(gGba);
}
