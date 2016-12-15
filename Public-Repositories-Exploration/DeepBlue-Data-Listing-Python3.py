
# coding: utf-8

# In[2]:

################################################################################
## Query Epigenetic Marks
## Adapted from DeepBlue API Examples

## Notes: 
## 1. The original script's modules don't work for python3.5. I updated a few commands
## 2. Python 2.6 or higher is required
################################################################################


## Connect to the server:
# import xmlrpclib #doesn't work on python3
import xmlrpc
import xmlrpc.client
#import xmlrpc.server


# In[3]:

## Set up the client:
url = "http://deepblue.mpi-inf.mpg.de/xmlrpc"
#server = xmlrpclib.Server(url, allow_none=True)
server = xmlrpc.client.ServerProxy(url, encoding='UTF-8', allow_none=True) #adapted for python3

## Use an anonymous key
## Alternatively, you can use your own key
user_key = "anonymous_key"


# In[4]:

## List all projects
server.list_projects(user_key)
# The result will be similar to ['okay', [['p1', 'ENCODE'], ['p2', 'BLUEPRINT Epigenome'], ['p5', 'Roadmap Epigenomics']]]


# In[15]:

help(server.list_experiments)


# In[5]:

## List all registered epigenetic marks: 
server.lst_epigenetic_marks(None, user_key)
# Part of the output will be ['okay', [['em1', 'DNA Methylation'], ['em10', 'Input'], ['em100', 'H3K9/14ac'], ['em101', 'H4K12ac'], ...


# In[8]:

## Query 1: List all experiments with H3k27ac peak data (.BED) & by ENCODE/BLUEPRINT
(status, peaks_experiments) = server.list_experiments("", "peaks", "H3K27ac", "", "", "", ["ENCODE", "Blueprint Epigenome"], user_key)

len(peaks_experiments) #expect >400 expts


# In[7]:

## Query 2: List all experiments with H3k27ac signals (.bedgraph, .wig) & by ENCODE or BLUEPRINT projects
(status, signal_experiments) = server.list_experiments("", "signal", "H3K27ac", "", "", "", ["ENCODE", "Blueprint Epigenome"], user_key)
len(signal_experiments)


# In[13]:

## Query 3: List all experiments with RRBS data
(status, signal_experiments) = server.list_experiments("", "", "", "", "", "", ["ENCODE", "Blueprint Epigenome"], user_key)
len(signal_experiments)


# In[ ]:



