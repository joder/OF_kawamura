#!/usr/bin/env -S awk -f

BEGIN{
    # Default for replacement. Call as
    # ./scripts/scalarToT.awk -v name=T0025 0/T0025 > 0/T
    if (!name) {
        name="T071"
    }
}
/object/{sub(name,"T",$0)}
/gradient +uniform +-[0-9.e+-]+/{sub("-","",$0)}
!start&&/^internalField +nonuniform +List<scalar>/{start=NR}
start&&/^)$/{start=0}
start&&NR<start+3
start&&NR>=start+3{printf "%16.8e\n", 600-$0}
!start
