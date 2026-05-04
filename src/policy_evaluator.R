# calculate policy payouts from losses

export("find_payout")
find_payout = function(policies, losses, 
                       parameters =list(
# TODO - Replace activityNames list with activityNames from the parameters file
                         activityNames = c(11, 21, 22, 23, 31, 42, 44, 48, 51, 52, 53, 54, 55, 56, 61, 62, 71, 72, 81, 92)
                       )) {
  rowParticipation = policies$Participation * policies$Policy.Count
  remainingAgg = policies$Risk.Annual.Aggregate.Layer.Limit * rowParticipation
  attachment = policies$Attachment.Point.for.Excess.Treaties
  payoutLimit = policies$Risk.per.Occurrence.Layer.Limit * rowParticipation
  bandMinima = parameters$alaeBandMinima
  bandFractions = parameters$alaeBandFractions
  # subtract from layerLimit after each event
  # get num events
  numEvents = dim(losses)[2] # length along 2nd axis (event)
  # iterate through events
  numPolicies = dim(policies)[1]
  payouts = array(0, dim = c(numPolicies, numEvents),
                  dimnames = list(rownames(policies), colnames(losses)))
  if(numEvents == 0) {
    return(payouts)
  }
  for (eventIdx in 1:numEvents) {
    cat("Event", eventIdx, "\n")
    loss = losses[,eventIdx][paste("Company",policies$Insured.ID)]
    # Pre-ALAE post-policy-terms payout drives the band lookup, regardless of alaeBeforePolicyTerms.
    tentativeInLayer = pmax(0, loss - attachment) * rowParticipation
    tentativePayout = pmin(tentativeInLayer, payoutLimit, remainingAgg)
    alaeFrac = bandFractions[findInterval(tentativePayout, bandMinima)]
    if(parameters$alaeBeforePolicyTerms) {
      grossLoss = loss * (1 + alaeFrac)
      inLayerLoss = pmax(0, grossLoss - attachment) * rowParticipation
      payout = pmin(inLayerLoss, payoutLimit, remainingAgg)
      aggregateBurn = payout
    } else {
      inLayerLoss = tentativeInLayer
      payout = tentativePayout * (1 + alaeFrac)
      aggregateBurn = tentativePayout
    }
    cat("Excess loss:\n")
    print(inLayerLoss)
    cat("Payout per Event Limit:\n")
    print(payoutLimit)
    cat("Remaining Layer Aggregate:\n")
    print(remainingAgg)
    cat("Banded ALAE fraction:\n")
    print(alaeFrac)
    cat("Payout:\n")
    print(payout)
    payouts[,eventIdx] = payout
    remainingAgg = remainingAgg - aggregateBurn
  }
  cat("\n\nAll payouts:\n")
  print(payouts)
  cat("\n\n========================================================================\n\n")
  return(payouts)
}