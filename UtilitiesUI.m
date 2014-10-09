//
//  UtilitiesUI.m
//
/*  Created by Gary Morris on 3/12/10.
 *  Copyright 2010-2011 Gary A. Morris. All rights reserved.
 *
 * This file is part of SDK_Utilities.repo
 *
 * This is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this file. If not, see <http://www.gnu.org/licenses/>.
 */

#import "UtilitiesUI.h"


#ifdef DEBUG
//-----------------------------------------------------------------------------
// dumpView
//-----------------------------------------------------------------------------
void dumpView(UIView* aView, NSString* indent, BOOL showLayers)
{
	if (aView) {
		NSLog(@"%@%@", indent, aView);		// dump this view
		
        NSString* subIndent = [[NSString alloc] initWithFormat:@"%@%@", 
                               indent, ([indent length]/2)%2==0 ? @"| " : @": "];

        if (showLayers) dumpLayer(aView.layer, subIndent);
        
		if (aView.subviews.count > 0) {		
			// dump its subviews
			for (UIView* aSubview in aView.subviews) {
                dumpView( aSubview, subIndent, showLayers );
            }
			
		}
	}
}

void dumpLayer(CALayer* aLayer, NSString* indent) 
{
    if (aLayer) {
        NSLog(@"%@%@ frame=%@", indent, aLayer, NSStringFromCGRect(aLayer.frame));     // dump this layer
        
        if (aLayer.sublayers.count > 0) {
			NSString* subIndent = [[NSString alloc] initWithFormat:@"%@%@", 
                                   indent, ([indent length]/2)%2==0 ? @"| " : @": "];
            
			// dump its subviews
			for (CALayer* aSublayer in aLayer.sublayers) dumpLayer( aSublayer, subIndent );
		}
    }
}

#endif
