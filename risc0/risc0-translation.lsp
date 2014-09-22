(in-package "ACL2")
(include-book "centaur/tutorial/intro" :dir :system) 

(plev)

(defmodules *risc0-translation*
  (vl::make-vl-loadconfig
   :start-files (list
                 "lib/BUFG.v"
                 "lib/IBUFG.v"
                 "lib/MULT18X18.v"

                 "src/PROM.v"
                 "src/DRAM.v"
                 "src/Multiplier.v"
                 "src/Multiplier1.v"
                 "src/Divider.v"
                 "src/RISC0.v"
                 "src/RS232R.v"
                 "src/RS232T.v"
                 "src/RISC0Top.v")))

(defmacro risc0-vl (name modname)
  `(defconst ,name
     (vl::vl-find-module ,modname
                         (vl::vl-design->mods
                           (vl::vl-translation->good *risc0-translation*)))))

(risc0-vl *bufg-vl*         "BUFG")
(risc0-vl *ibufg-vl*        "IBUFG")
(risc0-vl *mult18x18-vl*    "MULT18X18")
(risc0-vl *prom-vl*         "PROM")
(risc0-vl *dram-vl*         "DRAM")
(risc0-vl *multiplier-vl*   "Multiplier")
(risc0-vl *multiplier1-vl*  "Multiplier1")
(risc0-vl *divider-vl*      "Divider")
(risc0-vl *risc0-vl*        "RISC0")
(risc0-vl *rs232r-vl*       "RS232R")
(risc0-vl *rs232t-vl*       "RS232T")
(risc0-vl *risc0top-vl*     "RISC0TOP")

(vl::vl-ppcs-module *bufg-vl*)
(vl::vl-ppcs-module *ibufg-vl*)
(vl::vl-ppcs-module *mult18x18-vl*)
(vl::vl-ppcs-module *prom-vl*)
(vl::vl-ppcs-module *dram-vl*)
(vl::vl-ppcs-module *multiplier-vl*)
(vl::vl-ppcs-module *multiplier1-vl*)
(vl::vl-ppcs-module *divider-vl*)
(vl::vl-ppcs-module *risc0-vl*)
(vl::vl-ppcs-module *rs232r-vl*)
(vl::vl-ppcs-module *rs232t-vl*)
(vl::vl-ppcs-module *risc0top-vl*)

