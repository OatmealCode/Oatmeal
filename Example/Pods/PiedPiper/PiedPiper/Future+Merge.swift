extension SequenceType where Generator.Element: Async {
  /**
  Merges this sequence of Futures into a single one containing the list of the results of each Future 
   
  - returns: A Future that will succeed with the list of results of the single Futures contained in this Sequence. The resulting Future will fail or be canceled if one of the elements of this sequence fails or is canceled
  */
  public func merge() -> Future<[Generator.Element.Value]> {
    return reduce([], combine: { accumulator, value in
      accumulator + [value]
    })
  }
}