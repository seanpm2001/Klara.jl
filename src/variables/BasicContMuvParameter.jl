### BasicContMuvParameter

type BasicContMuvParameter{S<:VariableState} <: Parameter{Continuous, Multivariate}
  key::Symbol
  index::Int
  pdf::Union{ContinuousMultivariateDistribution, Void}
  prior::Union{ContinuousMultivariateDistribution, Void}
  setpdf::Union{Function, Void}
  setprior::Union{Function, Void}
  loglikelihood!::Union{Function, Void}
  logprior!::Union{Function, Void}
  logtarget!::Union{Function, Void}
  gradloglikelihood!::Union{Function, Void}
  gradlogprior!::Union{Function, Void}
  gradlogtarget!::Union{Function, Void}
  tensorloglikelihood!::Union{Function, Void}
  tensorlogprior!::Union{Function, Void}
  tensorlogtarget!::Union{Function, Void}
  dtensorloglikelihood!::Union{Function, Void}
  dtensorlogprior!::Union{Function, Void}
  dtensorlogtarget!::Union{Function, Void}
  uptogradlogtarget!::Union{Function, Void}
  uptotensorlogtarget!::Union{Function, Void}
  uptodtensorlogtarget!::Union{Function, Void}
  states::Vector{S}

  function BasicContMuvParameter(
    key::Symbol,
    index::Int,
    pdf::Union{ContinuousMultivariateDistribution, Void},
    prior::Union{ContinuousMultivariateDistribution, Void},
    setpdf::Union{Function, Void},
    setprior::Union{Function, Void},
    ll::Union{Function, Void},
    lp::Union{Function, Void},
    lt::Union{Function, Void},
    gll::Union{Function, Void},
    glp::Union{Function, Void},
    glt::Union{Function, Void},
    tll::Union{Function, Void},
    tlp::Union{Function, Void},
    tlt::Union{Function, Void},
    dtll::Union{Function, Void},
    dtlp::Union{Function, Void},
    dtlt::Union{Function, Void},
    uptoglt::Union{Function, Void},
    uptotlt::Union{Function, Void},
    uptodtlt::Union{Function, Void},
    states::Vector{S}
  )
    args = (setpdf, setprior, ll, lp, lt, gll, glp, glt, tll, tlp, tlt, dtll, dtlp, dtlt, uptoglt, uptotlt, uptodtlt)
    fnames = fieldnames(BasicContMuvParameter)[5:21]

    # Check that all generic functions have correct signature
    for i = 1:17
      if isa(args[i], Function) &&
        isgeneric(args[i]) &&
        !(any([method_exists(args[i], (BasicContMuvParameterState, Vector{S})) for S in subtypes(VariableState)]))
        error("$(fnames[i]) has wrong signature")
      end
    end

    new(
      key,
      index,
      pdf,
      prior,
      setpdf,
      setprior,
      ll,
      lp,
      lt,
      gll,
      glp,
      glt,
      tll,
      tlp,
      tlt,
      dtll,
      dtlp,
      dtlt,
      uptoglt,
      uptotlt,
      uptodtlt,
      states
    )
  end
end

BasicContMuvParameter{S<:VariableState}(
  key::Symbol,
  index::Int,
  pdf::Union{ContinuousMultivariateDistribution, Void},
  prior::Union{ContinuousMultivariateDistribution, Void},
  setpdf::Union{Function, Void},
  setprior::Union{Function, Void},
  ll::Union{Function, Void},
  lp::Union{Function, Void},
  lt::Union{Function, Void},
  gll::Union{Function, Void},
  glp::Union{Function, Void},
  glt::Union{Function, Void},
  tll::Union{Function, Void},
  tlp::Union{Function, Void},
  tlt::Union{Function, Void},
  dtll::Union{Function, Void},
  dtlp::Union{Function, Void},
  dtlt::Union{Function, Void},
  uptoglt::Union{Function, Void},
  uptotlt::Union{Function, Void},
  uptodtlt::Union{Function, Void},
  states::Vector{S}
) =
  BasicContMuvParameter{S}(
    key,
    index,
    pdf,
    prior,
    setpdf,
    setprior,
    ll,
    lp,
    lt,
    gll,
    glp,
    glt,
    tll,
    tlp,
    tlt,
    dtll,
    dtlp,
    dtlt,
    uptoglt,
    uptotlt,
    uptodtlt,
    states
  )

function BasicContMuvParameter!(
  parameter::BasicContMuvParameter,
  setpdf::Union{Function, Void},
  setprior::Union{Function, Void},
  ll::Union{Function, Void},
  lp::Union{Function, Void},
  lt::Union{Function, Void},
  gll::Union{Function, Void},
  glp::Union{Function, Void},
  glt::Union{Function, Void},
  tll::Union{Function, Void},
  tlp::Union{Function, Void},
  tlt::Union{Function, Void},
  dtll::Union{Function, Void},
  dtlp::Union{Function, Void},
  dtlt::Union{Function, Void},
  uptoglt::Union{Function, Void},
  uptotlt::Union{Function, Void},
  uptodtlt::Union{Function, Void}
)
  args = (setpdf, setprior, ll, lp, lt, gll, glp, glt, tll, tlp, tlt, dtll, dtlp, dtlt, uptoglt, uptotlt, uptodtlt)

  # Define setpdf (i = 1) and setprior (i = 2)
  for (i, setter, distribution) in ((1, :setpdf, :pdf), (2, :setprior, :prior))
    setfield!(
      parameter,
      setter,
      if isa(args[i], Function)
        eval(codegen_setfield_basiccontmuvparameter(parameter, distribution, args[i]))
      else
        nothing
      end
    )
  end

  # Define loglikelihood! (i = 3) and gradloglikelihood! (i = 6)
  # plfield stands for parameter likelihood-related field respectively
  for (i, plfield) in ((3, :loglikelihood!), (6, :gradloglikelihood!))
    setfield!(
      parameter,
      plfield,
      if isa(args[i], Function)
        eval(codegen_method_basiccontmuvparameter(parameter, args[i]))
      else
        nothing
      end
    )
  end

  # Define logprior! (i = 4) and gradlogprior! (i = 7)
  # ppfield and spfield stand for parameter prior-related field and state prior-related field repsectively
  for (i , ppfield, spfield, f) in ((4, :logprior!, :logprior, logpdf), (7, :gradlogprior!, :gradlogprior, gradlogpdf))
    setfield!(
    parameter,
      ppfield,
      if isa(args[i], Function)
        eval(codegen_method_basiccontmuvparameter(parameter, args[i]))
      else
        if (
            isa(parameter.prior, ContinuousMultivariateDistribution) &&
            method_exists(f, (typeof(parameter.prior), Vector{eltype(parameter.prior)}))
          ) ||
          isa(args[2], Function)
          eval(codegen_method_via_distribution_basiccontmuvparameter(parameter, :prior, f, spfield))
        else
          nothing
        end
      end
    )
  end

  # Define logtarget! (i = 5) and gradlogtarget! (i = 8)
  # ptfield, plfield and ppfield stand for parameter target, likelihood and prior-related field respectively
  # stfield, slfield and spfield stand for state target, likelihood and prior-related field respectively
  for (i , ptfield, plfield, ppfield, stfield, slfield, spfield, f) in (
    (5, :logtarget!, :loglikelihood!, :logprior!, :logtarget, :loglikelihood, :logprior, logpdf),
    (8, :gradlogtarget!, :gradloglikelihood!, :gradlogprior!, :gradlogtarget, :gradloglikelihood, :gradlogprior, gradlogpdf)
  )
    setfield!(
      parameter,
      ptfield,
      if isa(args[i], Function)
        eval(codegen_method_basiccontmuvparameter(parameter, args[i]))
      else
        if isa(args[i-2], Function) && isa(getfield(parameter, ppfield), Function)
          eval(codegen_method_via_sum_basiccontmuvparameter(parameter, plfield, ppfield, stfield, slfield, spfield))
        elseif (
            isa(parameter.pdf, ContinuousMultivariateDistribution) &&
            method_exists(f, (typeof(parameter.pdf), Vector{eltype(parameter.pdf)}))
          ) ||
          isa(args[1], Function)
          eval(codegen_method_via_distribution_basiccontmuvparameter(parameter, :pdf, f, stfield))
        else
          nothing
        end
      end
    )
  end

  # Define tensorloglikelihood! (i = 9) and dtensorloglikelihood! (i = 12)
  # plfield stands for parameter likelihood-related field respectively
  for (i, plfield) in ((9, :tensorloglikelihood!), (12, :dtensorloglikelihood!))
    setfield!(
      parameter,
      plfield,
      if isa(args[i], Function)
        eval(codegen_method_basiccontmuvparameter(parameter, args[i]))
      else
        nothing
      end
    )
  end

  # Define tensorlogprior! (i = 10) and dtensorlogprior! (i = 13)
  # ppfield stands for parameter prior-related field respectively
  for (i, ppfield) in ((10, :tensorlogprior!), (13, :dtensorlogprior!))
    setfield!(
      parameter,
      ppfield,
      if isa(args[i], Function)
        eval(codegen_method_basiccontmuvparameter(parameter, args[i]))
      else
        nothing
      end
    )
  end

  # Define tensorlogtarget! (i = 11) and dtensorlogtarget! (i = 14)
  for (i , ptfield, plfield, ppfield, stfield, slfield, spfield) in (
    (
      11,
      :tensorlogtarget!, :tensorloglikelihood!, :tensorlogprior!,
      :tensorlogtarget, :tensorloglikelihood, :tensorlogprior
    ),
    (
      14,
      :dtensorlogtarget!, :dtensorloglikelihood!, :dtensorlogprior!,
      :dtensorlogtarget, :dtensorloglikelihood, :dtensorlogprior
    )
  )
    setfield!(
      parameter,
      ptfield,
      if isa(args[i], Function)
        eval(codegen_method_basiccontmuvparameter(parameter, args[i]))
      else
        if isa(args[i-2], Function) && isa(args[i-1], Function)
          eval(codegen_method_via_sum_basiccontmuvparameter(parameter, plfield, ppfield, stfield, slfield, spfield))
        else
          nothing
        end
      end
    )
  end

  # Define uptogradlogtarget!
  setfield!(
    parameter,
    :uptogradlogtarget!,
    if isa(args[15], Function)
      eval(codegen_method_basiccontmuvparameter(parameter, args[15]))
    else
      if isa(parameter.logtarget!, Function) && isa(parameter.gradlogtarget!, Function)
        eval(codegen_uptomethods_basiccontmuvparameter(parameter, [:logtarget!, :gradlogtarget!]))
      else
        nothing
      end
    end
  )

  # Define uptotensorlogtarget!
  setfield!(
    parameter,
    :uptotensorlogtarget!,
    if isa(args[16], Function)
      eval(codegen_method_basiccontmuvparameter(parameter, args[16]))
    else
      if isa(parameter.logtarget!, Function) &&
        isa(parameter.gradlogtarget!, Function) &&
        isa(parameter.tensorlogtarget!, Function)
        eval(codegen_uptomethods_basiccontmuvparameter(parameter, [:logtarget!, :gradlogtarget!, :tensorlogtarget!]))
      else
        nothing
      end
    end
  )

  # Define uptodtensorlogtarget!
  setfield!(
    parameter,
    :uptodtensorlogtarget!,
    if isa(args[17], Function)
      eval(codegen_method_basiccontmuvparameter(parameter, args[17]))
    else
      if isa(parameter.logtarget!, Function) &&
        isa(parameter.gradlogtarget!, Function) &&
        isa(parameter.tensorlogtarget!, Function) &&
        isa(parameter.dtensorlogtarget!, Function)
        eval(codegen_uptomethods_basiccontmuvparameter(
          parameter, [:logtarget!, :gradlogtarget!, :tensorlogtarget!, :dtensorlogtarget!]
        ))
      else
        nothing
      end
    end
  )
end

function BasicContMuvParameter{S<:VariableState}(
  key::Symbol,
  index::Int=0;
  pdf::Union{ContinuousMultivariateDistribution, Void}=nothing,
  prior::Union{ContinuousMultivariateDistribution, Void}=nothing,
  setpdf::Union{Function, Void}=nothing,
  setprior::Union{Function, Void}=nothing,
  loglikelihood::Union{Function, Void}=nothing,
  logprior::Union{Function, Void}=nothing,
  logtarget::Union{Function, Void}=nothing,
  gradloglikelihood::Union{Function, Void}=nothing,
  gradlogprior::Union{Function, Void}=nothing,
  gradlogtarget::Union{Function, Void}=nothing,
  tensorloglikelihood::Union{Function, Void}=nothing,
  tensorlogprior::Union{Function, Void}=nothing,
  tensorlogtarget::Union{Function, Void}=nothing,
  dtensorloglikelihood::Union{Function, Void}=nothing,
  dtensorlogprior::Union{Function, Void}=nothing,
  dtensorlogtarget::Union{Function, Void}=nothing,
  uptogradlogtarget::Union{Function, Void}=nothing,
  uptotensorlogtarget::Union{Function, Void}=nothing,
  uptodtensorlogtarget::Union{Function, Void}=nothing,
  states::Vector{S}=VariableState[]
)
  parameter = BasicContMuvParameter(key, index, pdf, prior, fill(nothing, 17)..., states)

  BasicContMuvParameter!(
    parameter,
    setpdf,
    setprior,
    loglikelihood,
    logprior,
    logtarget,
    gradloglikelihood,
    gradlogprior,
    gradlogtarget,
    tensorloglikelihood,
    tensorlogprior,
    tensorlogtarget,
    dtensorloglikelihood,
    dtensorlogprior,
    dtensorlogtarget,
    uptogradlogtarget,
    uptotensorlogtarget,
    uptodtensorlogtarget
  )

  parameter
end

function BasicContMuvParameter{S<:VariableState}(
  key::Vector{Symbol},
  index::Int;
  pdf::Union{ContinuousMultivariateDistribution, Void}=nothing,
  prior::Union{ContinuousMultivariateDistribution, Void}=nothing,
  setpdf::Union{Function, Void}=nothing,
  setprior::Union{Function, Void}=nothing,
  loglikelihood::Union{Function, Expr, Void}=nothing,
  logprior::Union{Function, Expr, Void}=nothing,
  logtarget::Union{Function, Expr, Void}=nothing,
  gradloglikelihood::Union{Function, Void}=nothing,
  gradlogprior::Union{Function, Void}=nothing,
  gradlogtarget::Union{Function, Void}=nothing,
  tensorloglikelihood::Union{Function, Void}=nothing,
  tensorlogprior::Union{Function, Void}=nothing,
  tensorlogtarget::Union{Function, Void}=nothing,
  dtensorloglikelihood::Union{Function, Void}=nothing,
  dtensorlogprior::Union{Function, Void}=nothing,
  dtensorlogtarget::Union{Function, Void}=nothing,
  uptogradlogtarget::Union{Function, Void}=nothing,
  uptotensorlogtarget::Union{Function, Void}=nothing,
  uptodtensorlogtarget::Union{Function, Void}=nothing,
  states::Vector{S}=VariableState[],
  nkeys::Int=length(key),
  vfarg::Bool=false,
  autodiff::Symbol=:none,
  order::Int=1,
  chunksize::Int=0,
  init::Vector=fill(nothing, 3)
)
  inargs = (
    setpdf,
    setprior,
    loglikelihood,
    logprior,
    logtarget,
    gradloglikelihood,
    gradlogprior,
    gradlogtarget,
    tensorloglikelihood,
    tensorlogprior,
    tensorlogtarget,
    dtensorloglikelihood,
    dtensorlogprior,
    dtensorlogtarget,
    uptogradlogtarget,
    uptotensorlogtarget,
    uptodtensorlogtarget
  )

  fnames = Array(Any, 17)
  fnames[1:2] = fill(Symbol[], 2)
  fnames[3:14] = [Symbol[f] for f in fieldnames(BasicContMuvParameterState)[2:13]]
  for i in 1:3
    fnames[14+i] = Symbol[fnames[j][1] for j in 5:3:(5+i*3)]
  end

  for i in 3:5
    if isa(inargs[i], Expr) && autodiff != :reverse
      error("The only case $(fnames[i][1]) can be an expression is when used in conjunction with reverse mode autodiff")
    end
  end

  if nkeys > 0
    if autodiff == :forward && vfarg
      error("In the case of forward mode autodiff, if nkeys is not 0, then vfarg must be false")
    elseif autodiff == :reverse
      error("In the case of reverse mode autodiff, the current implementation supports only nkeys = 0")
    end
  elseif nkeys < 0
    "nkeys must be non-negative, got $nkeys"
  end

  if !in(autodiff, (:none, :forward, :reverse))
    error("autodiff must be :nore or :forward or :reverse, got $autodiff")
  end

  if order < 0 || order > 1
    error("Derivative order must be 0 or 1, got $order")
  elseif autodiff != :reverse && order == 0
    error("Zero order can be used only with reverse mode autodiff")
  end

  @assert 0 <= order <= 3 "Derivative order must be 0 or 1 or 2 or 3, got $order"

  @assert chunksize >= 0 "chunksize must be non-negative, got $chunksize"

  if autodiff != :reverse
    @assert init == fill(nothing, 3) "init option is used only for reverse mode autodiff"
  else
    @assert length(init) == 3 "init must be a vector of length 3, got vector of length $(length(init))"

    for i in 1:3
      if isa(inargs[i], Function)
        if length(init[i]) != 1
          "init element for $(fnames[i][1]) must be a tuple of length 1, got tuple of length $(length(init[i]))"
        end
      elseif isa(inargs[i], Expr)
        if length(init[i]) != 2
          "init element for $(fnames[i][1]) must be a tuple of length 2, got tuple of length $(length(init[i]))"
        end
        if !isa(init[i][1], Symbol)
          "The first element of init for $(fnames[i][1]) must be a tuple, got element of type $(typeof(init[i][1]))"
        end
      else
        if init[i] != nothing
          "init element for $(fnames[i][1]) must be set to nothing, got init set to $(init[i])"
        end
      end
    end
  end

  parameter = BasicContMuvParameter(key[index], index, pdf, prior, fill(nothing, 17)..., states)

  outargs = Union{Function, Void}[nothing for i in 1:17]

  for i in 1:17
    if isa(inargs[i], Function)
      outargs[i] = eval(codegen_internal_variable_method(inargs[i], fnames[i], nkeys, vfarg))
    end
  end

  if autodiff == :forward
    fadclosure = Array(Union{Function, Void}, 3)
    for i in 3:5
      fadclosure[i-2] =
        if isa(inargs[i], Function)
          nkeys == 0 ? inargs[i] : eval(codegen_internal_forward_autodiff_closure(parameter, inargs[i]))
        else
          nothing
        end
    end

    for i in 6:8
      if !isa(inargs[i], Function) && isa(inargs[i-3], Function)
        outargs[i] = eval(codegen_internal_variable_method(
          forward_autodiff_function(:gradient, fadclosure[i-5], false, chunksize), fnames[i], nkeys, vfarg
        ))
      end
    end

    if !isa(inargs[15], Function) && isa(inargs[5], Function)
      outargs[15] = eval(codegen_internal_variable_method(
        eval(codegen_forward_autodiff_uptofunction(:gradient, fadclosure[3], chunksize)), fnames[15], nkeys, vfarg
      ))
    end

    # if order >= 2
    # end

    # if order == 3
    # end
  elseif autodiff == :reverse
    for i in 3:5
      if isa(inargs[i], Expr)
        outargs[i] = eval(codegen_internal_variable_method(
          eval(codegen_reverse_autodiff_function(inargs[i], :Vector, init[i-2], 0, false)), fnames[i], nkeys
        ))
      end
    end

    for i in 6:8
      if !isa(inargs[i], Function)
        if isa(inargs[i-3], Function)
          outargs[i] = eval(codegen_internal_variable_method(
            ReverseDiffSource.rdiff(inargs[i-3], init[i-5], order=1, allorders=false), fnames[i], nkeys
          ))
        elseif isa(inargs[i-3], Expr)
          outargs[i] = eval(codegen_internal_variable_method(
            eval(codegen_reverse_autodiff_function(inargs[i-3], :Vector, init[i-5], 1, false)), fnames[i], nkeys
          ))
        end
      end
    end

    if !isa(inargs[15], Function)
      if isa(inargs[5], Function)
        outargs[15] = eval(codegen_internal_variable_method(
          ReverseDiffSource.rdiff(inargs[5], init[3], order=1, allorders=true), fnames[15], nkeys
        ))
      elseif isa(inargs[5], Expr)
        outargs[15] = eval(codegen_internal_variable_method(
          eval(codegen_reverse_autodiff_function(inargs[5], :Vector, init[3], 1, true)), fnames[15], nkeys
        ))
      end
    end

    # if order >= 2
    # end

    # if order == 3
    # end
  end

  BasicContMuvParameter!(parameter, outargs...)

  parameter
end

function codegen_setfield_basiccontmuvparameter(parameter::BasicContMuvParameter, field::Symbol, f::Function)
  @gensym codegen_setfield_basiccontmuvparameter
  quote
    function $codegen_setfield_basiccontmuvparameter(_state::BasicContMuvParameterState)
      setfield!($(parameter), $(QuoteNode(field)), $(f)(_state, $(parameter).states))
    end
  end
end

function codegen_method_basiccontmuvparameter(parameter::BasicContMuvParameter, f::Function)
  @gensym codegen_method_basiccontmuvparameter
  quote
    function $codegen_method_basiccontmuvparameter(_state::BasicContMuvParameterState)
      $(f)(_state, $(parameter).states)
    end
  end
end

function codegen_method_via_distribution_basiccontmuvparameter(
  parameter::BasicContMuvParameter,
  distribution::Symbol,
  f::Function,
  field::Symbol
)
  @gensym codegen_method_via_distribution_basiccontmuvparameter
  quote
    function $codegen_method_via_distribution_basiccontmuvparameter(_state::BasicContMuvParameterState)
      setfield!(_state, $(QuoteNode(field)), $(f)(getfield($(parameter), $(QuoteNode(distribution))), _state.value))
    end
  end
end

function codegen_method_via_sum_basiccontmuvparameter(
  parameter::BasicContMuvParameter,
  plfield::Symbol,
  ppfield::Symbol,
  stfield::Symbol,
  slfield::Symbol,
  spfield::Symbol
)
  body = []

  push!(body, :(getfield($(parameter), $(QuoteNode(plfield)))(_state)))
  push!(body, :(getfield($(parameter), $(QuoteNode(ppfield)))(_state)))
  push!(body, :(setfield!(
    _state,
    $(QuoteNode(stfield)),
    getfield(_state, $(QuoteNode(slfield)))+getfield(_state, $(QuoteNode(spfield)))))
  )

  @gensym codegen_method_via_sum_basiccontmuvparameter

  quote
    function $codegen_method_via_sum_basiccontmuvparameter(_state::BasicContMuvParameterState)
      $(body...)
    end
  end
end

function codegen_uptomethods_basiccontmuvparameter(parameter::BasicContMuvParameter, fields::Vector{Symbol})
  body = []
  local f::Symbol

  for i in 1:length(fields)
    f = fields[i]
    push!(body, :(getfield($(parameter), $(QuoteNode(f)))(_state)))
  end

  @gensym codegen_uptomethods_basiccontmuvparameter

  quote
    function $codegen_uptomethods_basiccontmuvparameter(_state::BasicContMuvParameterState)
      $(body...)
    end
  end
end

function codegen_internal_forward_autodiff_closure(parameter::BasicContMuvParameter, f::Function)
  fstatesarg = [Expr(:ref, :Any, [:($(parameter).states[$i].value) for i in 1:$(parameter).nkeys]...)]

  @gensym internal_forward_autodiff_closure

  quote
    function $internal_forward_autodiff_closure(_x::Vector)
      $(f)(_x, $(fstatesarg...))
    end
  end
end

value_support(s::Type{BasicContMuvParameter}) = Continuous
value_support(s::BasicContMuvParameter) = Continuous

variate_form(s::Type{BasicContMuvParameter}) = Multivariate
variate_form(s::BasicContMuvParameter) = Multivariate

default_state{N<:Real}(variable::BasicContMuvParameter, value::Vector{N}, outopts::Dict) =
  BasicContMuvParameterState(
    value,
    [getfield(variable, fieldnames(BasicContMuvParameter)[i]) == nothing ? false : true for i in 10:18],
    (haskey(outopts, :diagnostics) && in(:accept, outopts[:diagnostics])) ? [:accept] : Symbol[]
  )
