python
import sys
sys.path.insert(0, '/home/bogdan/Build/utils/gdb')
from qt4 import register_qt4_printers
from kde4 import register_kde4_printers
from libstdcxx import register_libstdcxx_printers

register_qt4_printers (None)
register_kde4_printers (None)
register_libstdcxx_printers (None)

end

set print pretty on

