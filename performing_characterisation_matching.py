
# coding: utf-8

# In[ ]:

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
os.system('rm ' + project_name + '_characterisation.db')

parser=e2m.Ecospold2Matrix('/mnt/collection/current_Version_3.1_cutoff_ecoSpold02/', 
                           project_name,
                           prefer_pickles=True,
                           verbose=False)
self = parser
c = self.conn.cursor()
parser.get_labels()


oldeco_path = '/home/bill/documents/arda/dev_arda_client/data/ecoinvent/2.2/Ecoinvent22_ReCiPe108_H.mat'
matdict = scipy.io.loadmat(oldeco_path)
a = np.array(matlab_tools.mine_nested_array(matdict['STR'], ''), dtype=object)
self.STR_old = pd.DataFrame(a, columns=matlab_tools.mine_nested_array(matdict['STR_header'], '').squeeze().tolist())



# In[ ]:

parser.initialize_database()
parser.process_ecoinvent_elementary_flows()
self.integrate_flows_ecoinvent()


# In[ ]:

parser.read_characterisation()


# In[ ]:

parser.integrate_flows_recipe()
IPython.embed()
