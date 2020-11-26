import os  # noqa:F401
import sys
from IPython.core.magic import register_line_magic


@register_line_magic
def ex(line):
    """Alias for sys.last_value -- value of last uncaught exception"""
    return sys.last_value
