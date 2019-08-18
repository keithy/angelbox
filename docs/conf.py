# Extra installation notes
#
#> pip3 install guzzle_sphinx_theme
#> pip3 install sphinx-rtd-theme
#
# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# http://www.sphinx-doc.org/en/master/config

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

project = 'AngelBox'
copyright = '2019, Keithy@consultant.com'
author = 'Keith'
master_doc = 'index'

# The full version, including alpha/beta/rc tags
release = '0.1'

# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = ['recommonmark']

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------
# import guzzle_sphinx_theme
import sphinx_rtd_theme

# The theme to use for HTML and HTML Help pages
#html_theme_path = guzzle_sphinx_theme.html_theme_path()

#html_theme = 'alabaster'
#html_theme = 'guzzle_sphinx_theme'
html_theme = 'sphinx_rtd_theme'
# Adds an HTML table visitor to apply Bootstrap table classes
#html_translator_class = 'guzzle_sphinx_theme.HTMLTranslator'

# Register the theme as an extension to generate a sitemap.xml
#extensions.append("guzzle_sphinx_theme")
extensions.append("sphinx_rtd_theme")

# Guzzle theme options (see theme.conf for more information)
html_theme_options = {
    # Set the name of the project to appear in the sidebar
    "project_nav_name": "AngelBox",

    # Set the path to a special layout to include for the homepage
    #"index_template": "special_index.html",

    # Set your Disqus short name to enable comments
    # "disqus_comments_shortname": "my_disqus_comments_short_name",

    # Set you GA account ID to enable tracking
    # "google_analytics_account": "my_ga_account",

    # Path to a touch icon
    "touch_icon": "",

    # Specify a base_url used to generate sitemap.xml links. If not
    # specified, then no sitemap will be built.
    "base_url": "",

    # Allow a separate homepage from the master_doc
    "homepage": "index",

    # Allow the project link to be overriden to a custom URL.
    "projectlink": "http://gitlab.com/keithy/angelbox",
}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']
