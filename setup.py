from setuptools import setup

setup(
        name = 'ecospold2matrix',
        packages = ['ecospold2matrix',],
        version = '0.1.0',
        author = 'Guillaume Majeau-Bettez',
        license = open('LICENSE.txt').read(),
        description = "Class for recasting Ecospold2 LCA dataset into Leontief matrix representations or Supply and Use Tables",
        author_email = "guillaume.majeau-bettez@ntnu.no",
        long_description = open('README.md').read(),
        url = 'https://github.com/majeau-bettez/ecospold2matrix',
    setup_requires=['lxml', 'nose', 'numpy', 'pandas', 'python-dateutil', 
        'pytz', 'scipy', 'six', 'xlrd', 'xlwt'],
        include_package_data = True,
)
