#= src/util.jl
=#

crandn{T<:Real}(::Type{T}, dims::Integer...) = convert(Array{T}, randn(dims...))
for (elty, relty) in ((:Complex64, :Float32), (:Complex128, :Float64))
  @eval begin
    crandn(::Type{$elty}, dims::Integer...) =
      reinterpret($elty, crandn($relty, 2*dims[1], dims[2:end]...), (dims...))
  end
end

function getcols(trans::Symbol, A::AbstractMatrix, cols)
  chktrans(trans)
  return (trans == :n ? A[:,cols] : A[cols,:]')
end
function getcols{T}(trans::Symbol, A::AbstractLinOp{T}, cols)
  chktrans(trans)
  return (trans == :n ? A[:,cols] : A'[:, cols])
end

function orthcols!{T<:BlasFloat}(A::StridedMatrix{T}; thin::Bool=true)
  k = minimum(size(A))
  tau = Array(T, k)
  LAPACK.geqrf!(A, tau)
  Q = LAPACK.orgqr!(A, tau)
  if thin  return Q
  else     (A[:,k+1:end] = 0; return A)
  end
end

function orthrows!{T<:BlasFloat}(A::StridedMatrix{T}; thin::Bool=true)
  k = minimum(size(A))
  tau = Array(T, k)
  LAPACK.gelqf!(A, tau)
  Q = LAPACK.orglq!(A, tau)
  if thin  return Q
  else     (A[k+1:end,:] = 0; return A)
  end
end

function scalevec!(s::AbstractVector, x::AbstractVector)
  n = length(x)
  length(s) == n || throw(DimensionMismatch)
  for i = 1:n
    x[i] *= s[i]
  end
  x
end
function iscale!(A::AbstractMatrix, b::AbstractVector)
  m, n = size(A)
  length(b) == n || throw(DimensionMismatch)
  for j = 1:n
    bj = b[j]
    for i = 1:m
      A[i,j] /= bj
    end
  end
  A
end
function iscale!(b::AbstractVector, A::AbstractMatrix)
  m, n = size(A)
  length(b) == m || throw(DimensionMismatch)
  for j = 1:n, i = 1:m
    A[i,j] /= b[i]
  end
  A
end
function iscalevec!(s::AbstractVector, x::AbstractVector)
  n = length(x)
  length(s) == n || throw(DimensionMismatch)
  for i = 1:n
    x[i] /= s[i]
  end
  x
end