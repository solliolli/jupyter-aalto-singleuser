import pytest

@pytest.mark.parametrize(
    'mod', ['sklearn',
            'seaborn',
            'bs4',
            'lxml',
            'xlsxwriter',
            'xlwt',
            'gensim',
            'pdfplumber',
            'pyodbc',
            'pmdarima',
            'tweepy',
            ]
    )
def test_imports(mod):
    __import__(mod)
