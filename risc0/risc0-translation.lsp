(in-package "ACL2")

(include-book "centaur/sv/top" :dir :system)
(include-book "centaur/vl/loader/top" :dir :system)
;(include-book "centaur/gl/gl" :dir :system)
;(include-book "centaur/aig/g-aig-eval" :dir :system)
;(include-book "tools/plev-ccl" :dir :system)
;(include-book "centaur/misc/memory-mgmt" :dir :system)
;(include-book "support")
; cert_param: (hons-only)
; cert_param: (uses-glucose)

;(gl::def-gl-clause-processor sv-tutorial-glcp)

(make-event

; Disabling waterfall parallelism.

 (if (and (acl2::hons-enabledp state)
          (f-get-global 'acl2::parallel-execution-enabled state))
     (er-progn (set-waterfall-parallelism nil)
               (value '(value-triple nil)))
   (value '(value-triple nil))))

;(plev)
;(plev-info)

(defun make-coretype-range (msb lsb)
  (vl::make-vl-coretype
    :name :vl-reg
    :pdims (list
             (vl::make-vl-range
               :msb (vl::make-vl-literal :val (vl::make-vl-constint :origwidth 32 :value 31 :origtype :vl-signed :wasunsized t))
               :lsb (vl::make-vl-literal :val (vl::make-vl-constint :origwidth 32 :value  0 :origtype :vl-signed :wasunsized t))))
    :udims (list
             (vl::make-vl-range
               :msb (vl::make-vl-literal :val (vl::make-vl-constint :origwidth 32 :value msb :origtype :vl-signed :wasunsized t))
               :lsb (vl::make-vl-literal :val (vl::make-vl-constint :origwidth 32 :value lsb :origtype :vl-signed :wasunsized t))))))

(defconst *risc0-files*
 (list
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
  "src/RISC0Top.v"))

(defconst *risc0-vl-loadconfig* (vl::make-vl-loadconfig :start-files *risc0-files*))
(defconsts (*risc0-vl-loadresult* state) (vl::vl-load *risc0-vl-loadconfig*))
(defconst *risc0-vl-design* (vl::vl-loadresult->design *risc0-vl-loadresult*))
(defconst *risc0-vl-mods* (vl::vl-design->mods *risc0-vl-design*))
(defconsts (*risc0-svex-design* *risc0-simplified-good* *risc0-simplified-bad*)
    (b* (((mv errmsg svex-design good bad)
          (vl::vl-design->svex-design "RISC0Top" *risc0-vl-design* (vl::make-vl-simpconfig))))
      (and errmsg
           (raise "~@0~%" errmsg))
      (mv svex-design good bad)))

(vl::vl-design-reportcard *risc0-vl-design*)
(vl::vl-design-reportcard *risc0-simplified-good*)

(assert! (null (vl::vl-design->mods *risc0-simplified-bad*)))
(assert! (equal (sv::design->top *risc0-svex-design*) "RISC0Top"))
(assert! (equal
  (alist-keys (sv::design->modalist *risc0-svex-design*))
  (list
    "RS232T"
    "RS232R"
    "RISC0Top"
    "RISC0"
    (make-coretype-range 0 15)
    "PROM"
    "Multiplier1"
    "MULT18X18"
    "IBUFG"
    "Divider"
    "DRAM"
    (make-coretype-range 2047 0)
    "BUFG")))

(defund check-module (top)
  (mv-let (errmsg svex-design simplified-good simplified-bad)
          (vl::vl-design->svex-design top *risc0-vl-design* (vl::make-vl-simpconfig))
          (and
            (not errmsg)
            (subsetp-equal (sv::design->modalist svex-design)
                           (sv::design->modalist *risc0-svex-design*))
            (subsetp-equal (vl::vl-design->mods simplified-good)
                           (vl::vl-design->mods *risc0-simplified-good*))
            (null (vl::vl-design->mods simplified-bad)))))

(assert! (and
  (check-module "RS232T")
  (check-module "RS232R")
  (check-module "RISC0Top")
  (check-module "RISC0")
  (check-module "PROM")
  (check-module "Multiplier1")
  (check-module "MULT18X18")
  (check-module "IBUFG")
  (check-module "Divider")
  (check-module "DRAM")
  (check-module "BUFG")))

(defmacro risc0-sv (name modname)
  `(progn
    (defconst ,name (cdr (hons-get ,modname (sv::design->modalist *risc0-svex-design*))))))

(risc0-sv *bufg-sv*        "BUFG")
(risc0-sv *ibufg-sv*       "IBUFG")
(risc0-sv *mult18x18-sv*   "MULT18X18")
(risc0-sv *prom-sv*        "PROM")
(risc0-sv *dram-sv*        "DRAM")
(risc0-sv *multiplier-sv*  "Multiplier")
(risc0-sv *multiplier1-sv* "Multiplier1")
(risc0-sv *divider-sv*     "Divider")
(risc0-sv *risc0-sv*       "RISC0")
(risc0-sv *rs232r-sv*      "RS232R")
(risc0-sv *rs232t-sv*      "RS232T")
(risc0-sv *risc0top-s*     "RISC0Top")

(assert! (sv::module-p *bufg-sv*))
(assert! (equal (sv::module->wires *bufg-sv*)
  (list (sv::make-wire :name "I" :width 1 :low-idx 0 :type :wire :delay 0)
        (sv::make-wire :name "O" :width 1 :low-idx 0 :type :wire :delay 0))))
(assert! (equal (sv::module->insts *bufg-sv*) nil))
(sv::module->assigns *bufg-sv*)
(assert! (equal (sv::module->aliaspairs *bufg-sv*) nil))
#|
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
|#
