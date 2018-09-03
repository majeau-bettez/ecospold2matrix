import ecospold2matrix as e2m
import unittest
import pandas as pd
import pandas.util.testing as pdt
import numpy as np
# pylint: disable-msg=C0103


# TODO: make sure order is respected in final export
#[Apos, Fpos] = e2m.normalize_flows(Z, G, output, True)

class TestE2M(unittest.TestCase):


    def setUp(self):
        self.sysdir='./test_data/'
        self.name = 'test'

        prod = ['foo', 'waste']
        act = ['BAR', 'PUP']

        self.activities = pd.DataFrame(
                [['BAR', 0, '1984-12-18', '2008-08-01'],
                 ['PUB', 0, '1984-12-18', '2008-08-01']],
                index=['BAR','PUB'],
                columns=['activityId','activityType','startDate','endDate'])
        self.products = pd.DataFrame(
                [['foo', 'foo', 'kg', 'kg'],
                 ['waste', 'waste', 'kg', 'kg']],
                index=['foo','waste'],
                columns=['productId','productName','unitId','unitName'])

        self.inflows = pd.DataFrame(
                [['BAR_foo',    'BAR',  'foo',       0.3],
                 ['BAR_foo',    'PUB',  'waste',    -0.1],
                 ['PUB_waste',  'PUB',  'waste',    -0.02]],
                columns=['fileId', 'sourceActivityId', 'productId', 'amount'])

        outflow_list =[['BAR_foo',    'foo',  1., 100, 0],
                     ['PUB_waste',  'waste', -1., .01, 0]] 

        self.outflows = pd.DataFrame(
                outflow_list,
                columns=['fileId',
                         'productId',
                         'amount',
                         'productionVolume',
                         'outputGroup'],
                index=[row[0] for row in outflow_list])

        #self.Z = pd.DataFrame(
        #        [[ 0.3,      0.    ],
        #         [-0.1,     -0.02  ]], index=prod, columns=prod)

        self.elementary_flows = pd.DataFrame(
                [['BAR_foo', 'CO2',  10],
                ['PUB_waste', 'CH4', 0.3]],
                columns=['fileId', 'elementaryExchangeId', 'amount'])

        list_A_label = [['BAR_foo', 'kg'],
                        ['PUB_waste', 'kg']]
        self.A_label = pd.DataFrame(
                list_A_label,
                columns=['fileId','unit'],
                index = [row[0] for row in list_A_label])

        self.F_label = self.elementary_flows.iloc[:,1]
        self.F_label.index = self.F_label.values

        a = {'BAR_foo':   {'BAR_foo': 0.3,
                           'PUB_waste': -0.1},
             'PUB_waste': {'BAR_foo': np.nan,
                           'PUB_waste': 0.02}}
        self.A = pd.DataFrame.from_dict(a).reindex(index=self.A_label.index,
                                                   columns=self.A_label.index)

        f = {'BAR_foo'  : {'CH4': np.nan,
                           'CO2': 10.0},
             'PUB_waste': {'CH4': -0.3,
                           'CO2': np.nan}}

        self.F = pd.DataFrame.from_dict(f).reindex(index=self.F_label.index,
                                                   columns=self.A_label.index)

        z = {'BAR_foo':   {'BAR_foo': 30.0,
                           'PUB_waste': -10.0},
             'PUB_waste': {'BAR_foo': np.nan,
                           'PUB_waste': 0.00020000000000000001}}
        self.Z = pd.DataFrame.from_dict(z).reindex_like(self.A)


        g = {'BAR_foo':   {'CH4': np.nan,
                           'CO2': 1000.0},
             'PUB_waste': {'CH4': -0.0030000000000000001,
                           'CO2': np.nan}}
        self.G_pro = pd.DataFrame.from_dict(g).reindex_like(self.F)

    def test_execute_log(self):

        parser = e2m.Ecospold2Matrix(self.sysdir, self.name, verbose=True)

        c = parser.conn.cursor()
        c.executescript("""
            drop table if exists foo;
            create table foo (
                aName text  unique,
                anId    int unique);
            drop table if exists fou;
            create table fou (
                aName text  unique,
                anId    int unique);
                """)
        c.execute(""" insert or ignore into foo values ('soleil', NULL);""")
        c.execute(""" insert or ignore into foo values ('lune', NULL);""")
        c.execute(""" insert or ignore into fou values ('soleil', 8);""")

        sql_command = """ update foo
        set anId = (select distinct fou.anId
                    from fou where foo.aName = fou.aName)
        where foo.anId is NULL """

        print("Gonna test updatenull_log")
        changes = parser._updatenull_log(sql_command, 'foo', 'anId')
        assert(changes==1)

        print("Gonna test updatenull_log")
        changes = parser._updatenull_log(sql_command, 'foo', 'anId')
        assert(changes==0)


    def assert_same_but_roworder(self, x, y, cols=None):

        if cols is not None:
            # In case of meaningless indexes, order relative to column and
            # reindex
            x = x.sort(x.columns[cols])
            x = x.reset_index(drop=True)
            y = y.sort(y.columns[cols])
            y = y.reset_index(drop=True)
        else:
            # If index meaninful, sort relative to it
            x = x.sort()
            y = y.sort()

        pdt.assert_frame_equal(x,y)
        

    def test_extract_products(self):

        # Load test value from csv file
        products0 = pd.DataFrame.from_csv('./test_data/products.csv', sep='|')
        products0.rename(columns={'productId.1':'productId'}, inplace=True)

        # build product list
        parser = e2m.Ecospold2Matrix(self.sysdir, self.name)
        parser.extract_products()

        pdt.assert_frame_equal(products0, parser.products)

    def test_extract_activities(self):

        # Load test values from csv file
        activities0 = pd.read_csv('./test_data/activities.csv', sep='|', index_col=0)

        # build activity list
        parser = e2m.Ecospold2Matrix(self.sysdir, self.name)
        parser.extract_activities()

        pdt.assert_frame_equal(activities0, parser.activities)

    def test_build_STR(self):

        # Read test values from csv file
        STR0 = pd.read_csv('./test_data/STR.csv', sep='|', index_col=0)
        STR0.index.name = 'id'
        parser = e2m.Ecospold2Matrix(self.sysdir, self.name)
        parser.build_STR()

        pdt.assert_frame_equal(STR0, parser.STR)

    def test_build_PRO(self):
        # Read test values from csv file
        PRO0 = pd.read_table('./test_data/PRO.csv', sep='|', index_col=0)

        parser = e2m.Ecospold2Matrix(self.sysdir, self.name)
        parser.build_PRO()

        pdt.assert_frame_equal(PRO0, parser.PRO)



    def test_extract_flows(self):

        # Read test values from csv file
        inflows0 = pd.read_table('./test_data/inflows.csv', sep='|', index_col=0)
        outflows0 = pd.read_table('./test_data/outflows.csv', sep='|', index_col=0)
        elementary_flows0 = pd.read_table('./test_data/elementary_flows.csv',
                                          sep='|', index_col=0)

        parser = e2m.Ecospold2Matrix(self.sysdir, self.name)
        parser.extract_flows()

        self.assert_same_but_roworder(inflows0, parser.inflows, 0)
        self.assert_same_but_roworder(outflows0, parser.outflows,0)
        self.assert_same_but_roworder(elementary_flows0,
                                      parser.elementary_flows,0)

    def test_complement_labels(self):

        # Read test values from csv file
        PRO0 = pd.DataFrame.from_csv('./test_data/PRO_full.csv', sep='|')

        parser = e2m.Ecospold2Matrix(self.sysdir, self.name)
        products0 = pd.DataFrame.from_csv('./test_data/products.csv', sep='|')
        parser.products = products0.rename(columns={'productId.1':'productId'})
        parser.activities = pd.read_csv('./test_data/activities.csv',
                                        sep='|', index_col=0)
        parser.STR = pd.read_csv('./test_data/STR.csv', sep='|', index_col=0)
        parser.PRO = pd.read_table('./test_data/PRO.csv', sep='|', index_col=0)

        parser.complement_labels()

        pdt.assert_frame_equal(PRO0, parser.PRO)

        

    def test_build_AF(self):
        parser = e2m.Ecospold2Matrix(self.sysdir, self.name)
        parser.inflows = self.inflows
        parser.outflows = self.outflows
        parser.elementary_flows = self.elementary_flows
        parser.PRO = self.A_label
        parser.STR = self.F_label
        parser.build_AF()

        pdt.assert_frame_equal(self.A, parser.A)
        pdt.assert_frame_equal(self.F, parser.F)

    def test_build_AF_positive_waste(self):
        parser = e2m.Ecospold2Matrix(self.sysdir, self.name)
        parser.inflows = self.inflows
        parser.outflows = self.outflows
        parser.elementary_flows = self.elementary_flows
        parser.PRO = self.A_label
        parser.STR = self.F_label

        parser.positive_waste=True
        parser.build_AF()


        a = {'BAR_foo':   {'BAR_foo': 0.3,
                           'PUB_waste': 0.1},
             'PUB_waste': {'BAR_foo': np.nan,
                           'PUB_waste': 0.02}}
        f = {'BAR_foo'  : {'CH4': np.nan,
                           'CO2': 10.0},
             'PUB_waste': {'CH4': 0.3,
                           'CO2': np.nan}}

        A0 = pd.DataFrame.from_dict(a)
        F0 = pd.DataFrame.from_dict(f)

        A0 = A0.reindex(index=self.A_label.index, columns=self.A_label.index)
        F0 = F0.reindex(index=self.F_label.index, columns=self.A_label.index)


        pdt.assert_frame_equal(A0, parser.A)
        pdt.assert_frame_equal(F0, parser.F)

    def test_scale_up_AF(self):

        parser = e2m.Ecospold2Matrix(self.sysdir, self.name)
        parser.outflows = self.outflows
        parser.PRO = self.A_label
        parser.STR = self.F_label
        parser.A = self.A
        parser.F = self.F

        parser.scale_up_AF()
        pdt.assert_frame_equal(self.Z, parser.Z)
        pdt.assert_frame_equal(self.G_pro, parser.G_pro)





    def test_build_sut_trace(self):
        """ Test compilation of supply, use and elementary exchange tables,
        preserving traceability, from ecoinvent flow lists """

        testflows = self.inflows.copy()
        testflows.ix[1:2, 'sourceActivityId'] = None

        U0_index = pd.MultiIndex(levels=[['', 'BAR'], ['foo', 'waste']],
                                 labels=[[0, 1], [1, 0]],
                                 names=['sourceActivityId', 'productId'])
        U0 = pd.DataFrame([[-0.1, -0.02], [0.3, np.nan]],
                          index=U0_index,
                          columns=['BAR', 'PUB'])
        #U0.columns.name = 'activityId'
        #U0.index.name = 'productId'

        V0 = pd.DataFrame({'BAR': {'foo': 1, 'waste': np.nan},
                           'PUB': {'foo': np.nan, 'waste': -1}})

        G0 = pd.DataFrame({"BAR":{"CO2":10.0  ,"CH4":np.nan},
                           "PUB":{"CO2":np.nan,"CH4":0.3 }}
                         ).reindex(self.F_label.index)


        parser = e2m.Ecospold2Matrix(self.sysdir, self.name)
        parser.activities = self.activities
        parser.products = self.products
        parser.inflows = testflows
        parser.outflows = self.outflows
        parser.elementary_flows = self.elementary_flows
        parser.STR = self.F_label
        
        parser.build_sut()

        pdt.assert_frame_equal(parser.U, U0)
        pdt.assert_frame_equal(parser.V, V0)
        pdt.assert_frame_equal(parser.G_act, G0)

    def test_build_sut_untrace(self):

        """ Test compilation of supply, use and elementary exchange tables,
        aggregating away traceability, from ecoinvent flow lists """
        testflows = self.inflows.copy()
        testflows.iloc[1:2, 'sourceActivityId'] = None

        V0 = pd.DataFrame({'BAR': {'foo': 1, 'waste': np.nan},
                           'PUB': {'foo': np.nan, 'waste': -1}})

        G0 = pd.DataFrame({"BAR":{"CO2":10.0  ,"CH4":np.nan},
                           "PUB":{"CO2":np.nan,"CH4":0.3 }}
                         ).reindex(self.F_label.index)

        # untraceable use
        U0 = pd.DataFrame({"BAR":{"foo":0.3, "waste":-0.1},
                           "PUB":{"foo":np.nan, "waste":-0.02}})
        
        parser = e2m.Ecospold2Matrix(self.sysdir, self.name)
        parser.activities = self.activities
        parser.products = self.products
        parser.inflows = testflows
        parser.outflows = self.outflows
        parser.elementary_flows = self.elementary_flows
        parser.STR = self.F_label

        parser.build_sut(make_untraceable=True)
        
        pdt.assert_frame_equal(parser.U, U0)
        pdt.assert_frame_equal(parser.V, V0)
        pdt.assert_frame_equal(parser.G_act, G0)

    def test_whole_leontief_run(self):
        """ Not technically a unit test... More a
        it-runs-through-and-does-not-crash integration test"""

        parser = e2m.Ecospold2Matrix(self.sysdir, self.name)

if __name__ == '__main__':
    unittest.main()
