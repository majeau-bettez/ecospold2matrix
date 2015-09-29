fullrun = True

import ecospold2matrix as e2m
import imp
imp.reload(e2m)
import pandas as pd
pd.set_option('display.max_columns', None)
import numpy as np
import scipy.io
import sys
import os
import IPython
sys.path.append('/home/bill/software/Python/Modules/')
import matlab_tools
imp.reload(matlab_tools)

project_name = 'testing'

if fullrun:
    os.system('rm ' + project_name + '_characterisation.db')


parser=e2m.Ecospold2Matrix('/mnt/collection/current_Version_3.1_cutoff_ecoSpold02/', 
                           project_name,
                           prefer_pickles=True,
                           verbose=True)
self = parser
c = self.conn.cursor()

print("Getting ecoinvent labels in object")
parser.get_labels()

if fullrun:
    print("initialize database")
    parser.initialize_database()
    print("Processing ecoinvent flows")
    parser.process_ecoinvent_elementary_flows()
    print("reading characterised flows")
    parser.read_characterisation()
    parser.populate_complementary_tables()
    parser.integrate_flows()
    os.system('cp ' + project_name + '_characterisation.db start_characterisation.db')
    print('DONE!!!')


oldeco_path = '/home/bill/documents/arda/dev_arda_client/data/ecoinvent/2.2/Ecoinvent22_ReCiPe108_H.mat'
matdict = scipy.io.loadmat(oldeco_path)
a = np.array(matlab_tools.mine_nested_array(matdict['STR'], ''), dtype=object)
self.STR_old = pd.DataFrame(a, columns=matlab_tools.mine_nested_array(matdict['STR_header'], '').squeeze().tolist())
self.STR_old.rename(columns={'ecoinvent_name' : 'name3',
                             'recipe_name': 'name',
                             'simapro_name': 'name2'}, inplace = True)
print(self.STR_old.columns)
parser.integrate_old_labels()
print("Done with performing characterisation")
IPython.embed()
