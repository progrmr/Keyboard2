#ifndef Coffee_Radar_NSLayoutConstraint_h
#define Coffee_Radar_NSLayoutConstraint_h


// NSLC - creates an equality relationship between the same attribute on 2 different views
#define NSLC(pView,pToView,pAttr,pMultipler,pConstant) \
    [NSLayoutConstraint constraintWithItem:pView attribute:pAttr relatedBy:NSLayoutRelationEqual toItem:pToView attribute:pAttr multiplier:pMultipler constant:pConstant]
#define NSLC2(pView,pAttr,pToView,pToAttr,pMultipler,pConstant) \
[NSLayoutConstraint constraintWithItem:pView attribute:pAttr relatedBy:NSLayoutRelationEqual toItem:pToView attribute:pToAttr multiplier:pMultipler constant:pConstant]

#define NSLC_GE(pView,pAttr,pToView,pToAttr,pMultiplier,pConstant) \
    [NSLayoutConstraint constraintWithItem:pView attribute:pAttr relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:pToView attribute:pToAttr multiplier:pMultipler constant:pConstant]
#define NSLC_LE(pView,pAttr,pToView,pToAttr,pMultiplier,pConstant) \
    [NSLayoutConstraint constraintWithItem:pView attribute:pAttr relatedBy:NSLayoutRelationLessThanOrEqual toItem:pToView attribute:pToAttr multiplier:pMultipler constant:pConstant]

#define NSLConstraints(pFormat)    \
    [NSLayoutConstraint constraintsWithVisualFormat:pFormat options:NSLayoutFormatDirectionLeftToRight metrics:metrics views:viewsDict]

#define NSLCWidth(pView,pWidth)   [NSLayoutConstraint constraintWithItem:pView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:pWidth]
#define NSLCHeight(pView,pHeight) [NSLayoutConstraint constraintWithItem:pView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:pHeight]

#define AddConstraints(pArray)     [constraints addObjectsFromArray:pArray]
#define AddConstraint(pConstraint) [constraints addObject:pConstraint]

#define AddPConstraint(pPriority,pConstraint) \
    { NSLayoutConstraint* tmp = pConstraint; tmp.priority = pPriority; AddConstraint(tmp); }

// first parameter is an NSDictionary of metrics (or nil),
// subsequent parameters are variable names which are used exactly like
// the params to NSDictionaryOfVariableBindings()
#define NSDictionariesOfMetricsAndVariables(pMetricsDictionary,...) \
    NSDictionary* viewsDict     = _NSDictionaryOfVariableBindings(@"" # __VA_ARGS__, __VA_ARGS__, nil);  \
    NSDictionary* metrics       = pMetricsDictionary; \
    NSMutableArray* constraints = [NSMutableArray arrayWithCapacity:32];


#endif