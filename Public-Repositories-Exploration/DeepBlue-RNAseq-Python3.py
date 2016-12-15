
# coding: utf-8

# In[6]:

################################################################################
## Query Blueprint RNAseq data
## Adapted from DeepBlue API Examples

## Notes: 
## Python 2.6 or higher is required; adapted for Python3
################################################################################

import xmlrpc
import xmlrpc.client
import time
import os


# In[7]:

## Set up the client:
url = "http://deepblue.mpi-inf.mpg.de/xmlrpc"
#server = xmlrpclib.Server(url, allow_none=True)
server = xmlrpc.client.ServerProxy(url, encoding='UTF-8', allow_none=True) #adapted for python3

## Use an anonymous key
## Alternatively, you can use your own key
user_key = "anonymous_key"


# In[8]:

## Obtain genes regions
gene_names = ['CCR1', 'CD164', 'CD1D', 'CD2', 'CD34', 'CD3G', 'CD44']

## Select regions of selected genes
(status, q_genes) = server.select_genes(gene_names, "gencode v23", 
                                            None, None, None, user_key)

## Filter regions that are protein-coding:
(status, q_genes_regions) = server.filter_regions(q_genes,
                                                  "@GENE_ATTRIBUTE(gene_type)",
                                                  "==", "protein_coding",
                                                  "string", user_key)

## Select all T cell-related biosources: 
biosources = ['Regulatory T cell']
liver_biosource_names = []
for biosource in biosources:
    (status, biosources) = server.get_biosource_related(biosource, user_key)
    liver_biosource_names += server.extract_names(biosources)[1]

## Obtain mRNA experiments names
(status, experiments) = server.list_experiments("GRCh38", "signal", "mRNA",
                                                liver_biosource_names, "", "",
                                                "BLUEPRINT Epigenome",
                                                user_key)
hsc_experiment_names = server.extract_names(experiments)[1]


# In[3]:

requests = []
request_id_experiment = {}

## Perform aggregation
for hsc_experiment_name in hsc_experiment_names:
    (status, q_exp) = server.select_experiments(hsc_experiment_name, "", None,
                                                None, user_key)

    (status, q_agg) = server.aggregate(q_exp, q_genes_regions, "VALUE", user_key)

    (status, q_filtered) = server.filter_regions(q_agg, "@AGG.MEAN", ">", "0",
                                                 "number", user_key)

    print("Summarization and filtering of " + hsc_experiment_name)

    status, req = server.get_regions(q_filtered,
                    "CHROMOSOME,START,END,@AGG.MEAN,@AGG.MAX,@AGG.MIN", user_key)
    print(hsc_experiment_name, status, req)
    request_id_experiment[req] = hsc_experiment_name
    requests.append(req)


# In[ ]:

## Get status
requests_data = {}
print(requests)
print(request_id_experiment)

if not os.path.isdir("data/"):
    os.mkdir("data/")

while len(requests) > 0:
    print "It is still missing " + str(len(requests)) + " requests"
    for req in requests[:]:
        (s, ss) = server.info(req, user_key)
        print ss
        if ss[0]["state"] == "done":
            print ss[0]
            print "getting data from " + ss[0]["_id"]
            (s, data) = server.get_request_data(req, user_key)
            with open("data/" + request_id_experiment[req] + ".bed", 'wb') as f:
                f.write(data)
            requests.remove(req)
        if ss[0]["state"] == "failed":
            print ss
            requests.remove(req)
time.sleep(1.0)

