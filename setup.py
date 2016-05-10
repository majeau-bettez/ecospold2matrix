from setuptools import setup

setup(
    name='ecospold2matrix',
    packages=['ecospold2matrix', ],
    version='0.1.0',
    author='Guillaume Majeau-Bettez',
    license=open('LICENSE.txt').read(),
    description="Class for recasting Ecospold2 LCA dataset into Leontief matrix representations or Supply and Use Tables",
    author_email="guillaume.majeau-bettez@ntnu.no",
    long_description=open('README.md').read(),
    url='https://github.com/majeau-bettez/ecospold2matrix',
    setup_requires=['numpy >= 1.11.0', 'lxml', 'nose >= 1.3.7',  'pandas >= 0.18.1', 'python-dateutil >= 2.5.3',
                    'scipy >= 0.17.0', 'six >= 1.10.0', 'xlrd >= 0.9.4', 'xlwt >= 1.0.0'],
    include_package_data=True,
)
