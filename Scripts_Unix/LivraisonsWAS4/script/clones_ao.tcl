#
# CLONE
#


set clone(fullName_ccc_) [list Name $clone(name_ccc_)]



set clone(stdout_ccc_) [list Stdout $clone(Out_ccc_)]

set clone(stderr_ccc_) [list Stderr $clone(Err_ccc_)]

set clone(tracespec_ccc_) [list TraceSpec $clone(TraceSpec_ccc_)]
set clone(traceoutput_ccc_) [list TraceOutput $clone(TraceOutput_ccc_)]
#set clone(httptransattrbis_ccc_) [list $clone(timeout_ccc_) $clone(portattr_ccc_)]
set clone(httptransattr_ccc_) [list $clone(portattr_ccc_)]
set clone(transportattr_ccc_) [list Transports $clone(httptransattr_ccc_)]

set clone(webcontainerattr_ccc_) [list WebContainerConfig $clone(transportattr_ccc_)]

# Liste des attributs du clone
set clone(CloneAttributelist_ccc_) [list $clone(stdout_ccc_) $clone(stderr_ccc_) $clone(fullName_ccc_) $clone(tracespec_ccc_) $clone(traceoutput_ccc_) $clone(webcontainerattr_ccc_)]
