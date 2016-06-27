FROM jupyter/systemuser

# Additional TeX packages for notebooks with unicode characters
RUN apt-get update -q && \
        DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
	texlive-latex-extra \
	texlive-generic-recommended \
	texlive-xetex

# Disable Python 2 kernel
RUN mv /usr/local/share/jupyter/kernels/python2 /var/tmp/

# For plt.xkcd()
RUN cd /usr/share/fonts && \
	wget --quiet https://github.com/shreyankg/xkcd-desktop/raw/master/Humor-Sans.ttf
RUN fc-cache --system-only

# Hack to use xelatex instead of pdflatex
RUN sed -i -e '/ *latex_command =/s/pdflatex/xelatex/' /opt/conda/lib/python*/site-packages/nbconvert/exporters/pdf.py

# We install each package one by one instead of via requirements.txt because
# changes to the file would invalidate the docker build cache. This means that
# docker would need to repeat all package installations even if we were to only
# change one.
# 
# For the similar reasons, we put most frequently changed requirements at the
# bottom.

# For geospatial connector ; pfrontiera
RUN conda install --yes gdal==2.0.0 libgdal==2.0.0
RUN conda install --yes pyproj==1.9.5.1
RUN conda install --yes pysal==1.11.1
RUN conda install --yes shapely==1.5.13
RUN pip install geopy==1.11.0

# For ecology connector ; cboettig
RUN conda install --yes numexpr==2.6.0
RUN conda install --yes psycopg2==2.6.1

# For humanities connector ; troland
RUN conda install --yes gensim==0.12.4
RUN conda install --yes nltk==3.2.1
# models
RUN python -m nltk.downloader -d /usr/local/share/nltk_data averaged_perceptron_tagger
RUN python -m nltk.downloader -d /usr/local/share/nltk_data maxent_ne_chunker
# corpora
RUN python -m nltk.downloader -d /usr/local/share/nltk_data cmudict
RUN python -m nltk.downloader -d /usr/local/share/nltk_data wordnet
RUN python -m nltk.downloader -d /usr/local/share/nltk_data words
#
RUN python -m nltk.downloader -d /usr/local/share/nltk_data punkt

RUN pip install okpy==1.6.4
RUN pip install pypandoc==1.1.3
RUN pip install datascience==0.5.20
