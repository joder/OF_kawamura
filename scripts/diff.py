#!/usr/bin/env python3

"""This script calculates the average integral relative difference between two
1D datasets.

The first dataset is the reference, while the second is comapred. It uses
interpolation to construct the two functions (phi_ref and phi_comp) to be
copared. The difference is calcualted as

Diff = 1 / (b-a) \int_{a}^{b} \abs{ (phi_ref - phi_comp) / (phi_ref } dx"""

import pandas as pd

def average(x, y, norm=1):
    """Calculate average of function y given at positions x."""
    from scipy import integrate
    import numpy as np
    if norm == 2:
        return np.sqrt(integrate.simps(np.abs(y*y), x) / (x[-1] - x[0]))
    elif norm == 'inf':
        return np.max(np.abs(y))
    else:
        # norm == 1:
        return integrate.simps(np.abs(y), x) / (x[-1] - x[0])

def main(ref, comp):
    """Main function when run from command line."""
    d = diff(ref, comp)
    rd = rdiff(ref, comp)
    ad = average(ref.xnew, d)
    ard = average(ref.xnew, rd)
    ad2 = average(ref.xnew, d, norm=2)
    ard2 = average(ref.xnew, rd, norm=2)
    adinf = average(ref.xnew, d, norm='inf')
    ardinf = average(ref.xnew, rd, norm='inf')
    print(("%15s"*6)%("L1", "L1_rel", "L2", "L2_rel", "Linf", "Linf_rel"))
    print(("%15.7e"*6)%(ad, ard, ad2, ard2, adinf, ardinf))

def diff(a, b):
    """Calculate a-b in interpolated points."""
    (anew, bnew) = commonise(a, b)
    return anew - bnew

def commonise(a, b):
    """Bring data a and b to common values on intersecting interval."""
    import numpy as np
    a.interpolate()
    b.interpolate()
    aknots = a.func_.get_knots()
    bknots = b.func_.get_knots()
    xmin = max(aknots[0], bknots[0])
    xmax = min(aknots[-1], bknots[-1])
    assert(xmin < xmax)
    num = min(len(aknots), len(bknots))
    xnew = np.linspace(xmin, xmax, num)
    anew = a.newvalues(xnew)
    bnew = b.newvalues(xnew)
    return (anew, bnew)

def rdiff(a, b):
    """Calculate (a-b)/a in interpolated points."""
    (anew, bnew) = commonise(a, b)
    difference = anew - bnew
    return difference / anew

class data:
    def __init__(self, filename, x, y):
        self.filename_ = filename
        self.colx_ = x-1
        self.coly_ = y-1
        self.read_ = False
        self.interpolated_ = False
        self.newvalues_ = False
    def read(self):
        if not self.read_:
            self.data_ = pd.read_csv(self.filename_, delim_whitespace=True, \
                    na_values='------------', usecols=[self.colx_, self.coly_]).dropna().drop_duplicates()
            self.read_ = True
    def interpolate(self):
        from scipy.interpolate import UnivariateSpline
        self.read()
        if not self.interpolated_:
            self.func_ = UnivariateSpline(self.data_.iloc[:,0].tolist(), \
                    self.data_.iloc[:,1].tolist(), k=3, s=0)
            self.interpolated_ = True
    def newvalues(self, x, force=False):
        self.interpolate()
        if not self.newvalues_ or force:
            self.xnew = x
            self.ynew = self.func_(x)
            self.newvalues_ = True
        return self.ynew

def parse_args():
    """Argument parsing function."""
    import argparse
    parser = argparse.ArgumentParser(description='Calculate the average difference between two datasets')
    parser.add_argument('reference', help='Reference data file')
    parser.add_argument('comparison', help='Compared data file')
    parser.add_argument('--ref-col-x', help='Column x in reference file', default=1, type=int)
    parser.add_argument('--ref-col-y', help='Column y in reference file', default=2, type=int)
    parser.add_argument('--com-col-x', help='Column x in compared file', default=1, type=int)
    parser.add_argument('--com-col-y', help='Column y in compared file', default=2, type=int)
    return parser.parse_args()

if __name__ == '__main__':
    ARGS = parse_args()
    main(data(ARGS.reference, ARGS.ref_col_x, ARGS.ref_col_y), \
            data(ARGS.comparison, ARGS.com_col_x, ARGS.com_col_y))
