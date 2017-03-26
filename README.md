Ecospold2Matrix
===============

A Python class to parse an ecospold2 life cycle assessment dataset and arrange it as matrices for further calculations.

It can recast an Ecoinvent 3 database into a Leontief coefficient matrix with extensions, or it can arrange the unallocated Ecoinvent data as Supply and Use tables (SUT).


Basic functionality
-------------------

- Conveniently store and log all parameters relevant to the data manipulation
- Perform basic quality checks on data, and fix some potential issues
- Arrange allocated data as Leontief technical coefficient matrix, with environmental extensions and labels
- Arrange unallocated data as SUT
- Optionally, change sign conventions for waste treatment
- Optionally, scale elementary and intermediate flows to recorded production volumes
- Save matrices to various different formats

Installation
------------

Now the code can be installed with:

`pip install git+git://github.com/repo_owner/ecospold2matrix#egg=ecospold2matrix`

where
* `repo_owner` could be: majeau-bettez or tngTUDOR or any fork of the project


Simple Use case
----------------
```python
import ecospold2matrix as e2m

# Define parser object, with default and project-specific parameters
# Make sure that the path database/location holds the datasets and MasterData folders
parser = e2m.Ecospold2Matrix('/database/location/', project_name='eco31_cons', positive_waste=True)

# Assemble matrices, including scaled-up flow matrices, and save to csv-files
parser.ecospold_to_Leontief(fileformats=['csv'], with_absolute_flows=True)
```

Or else...


```python

import ecospold2matrix as em
charfile = 'ecoinvent_3.3_LCIA_implementation/LCIA_implementation_3.3.xlsx'
parser = em.Ecospold2Matrix(
        sys_dir = 'ecoinvent_3.3_consequential_ecoSpold02/',
        lci_dir = 'ecoinvent_3.3_consequential_lci_ecoSpold02/datasets',
        positive_waste=True,
        prefer_pickles=True,
        project_name='ecoinvent33cons',
        version_name='ecoinvent33')

parser.ecospold_to_Leontief(characterisation_file=charfile, lci_check=True)
```
Short Demo
----------
Have a look at this [Ipython notebook for a demo of typical usage](http://nbviewer.ipython.org/github/majeau-bettez/ecospold2matrix/blob/master/doc/ecospold2matrix_demo.ipynb)


Dependencies
------------

- Python 3
- Pandas
- Numpy
- Scipy
- lxml
- Six
- xlrd
- xlwt

Open Source
----------

This tool incorporates some code from the open-source [Brightway2 project](http://brightwaylca.org/). Ecospold2Matrix is also open-source, so feel most welcome to use, give feedback, modify or contribute.
