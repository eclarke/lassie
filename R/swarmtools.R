#' Identify sites under putative immune selection.
#' 
#' Given a serially sampled protein sequence alignment, this will list sites where loss of transmitted-founder (TF) form exceeds a cutoff value within a given sample timepoint.
#'
#' The sample timepoints should be part of the sequence names and it should be possible to extract them by splitting sequence names with a particular separator and taking one of the resulting fields as the timepoint label.  TF loss is computed among sequences that have the same timepoint label.  By default, the timepoint label is in the first dot-delimited field.  However, you can specify alternatives using lassie::create.timepoint.parser().
#'
#' You should provide at least the name of an alignment file or an alignment matrix (via seqinr::as.alignment.matrix()) 
#' already in memory, and specify a percentage value (0-100) for tf_loss_cutoff.  Without these, no sites will be returned.
#' This is not an error state, as the returned swarmtools object could be passed to lassie::set.alignment.file() and 
#' lassie::set.tf.loss.cutoff().
#'
#' @param aas_aln Alignment matrix.
#' @param aas_file Alignment file.
#' @param alignment_format Format of alignment file/s; must be one of these: \code{"fasta"}, \code{"clustal"}, \code{"phylip"}, \code{"msf"}, or \code{"mase"}.
#' @param tf_index TF index
#' @param tf_name TF name
#' @param timepoints_parser Timepoints parsing function
#' @param refseq_lut_file Reference sequence LUT file
#' @param refseq_lut Reference sequence lookup table
#' @param refseq_name Reference sequence name
#' @param tf_loss_cutoff Threshold value (or vector of values) for including a site
#' @param included_sites List of included sites
#' @param excluded_sites List of excluded sites
#'
#' @return swarmtools object
#'
#' @examples
#' \dontrun{
#'   A <- lassie::swarmtools(aas_file=system.file("extdata", "CH505-gp160.fasta", 
#'             package="lassie"), tf_loss_cutoff=80)
#'   B <- lassie::swarmset(A)
#' }
#' @export

swarmtools <- function(
    aas_aln=NULL,
    aas_file=NULL, 
    alignment_format="fasta", 
    tf_index=1,
    tf_name=NULL,
    timepoints_parser=NULL,
    refseq_lut_file=NULL,
    refseq_lut=NULL,
    refseq_name="HXB2",
    tf_loss_cutoff=NULL, # include sites with tf_loss at or above (>=) cutoff
    included_sites=NULL,
    excluded_sites=NULL) {

    if (is.null(timepoints_parser))
	timepoints_parser <- create.timepoint.parser(".", 1)

    retval <- list(aas_aln=NULL,
	aas_file=NULL, # this gets set below and triggers prep.aln
	alignment_format=alignment_format,
	n_per_timepoint=NULL,
	timepoints_parser=timepoints_parser,
	original_seqnames=NULL,
	tf_index=tf_index,
	tf_name=tf_name,
	is_tf=NULL, #is_tf,
	tf_loss=NULL, #tf_loss,
	peak_tf_loss=NULL, #peak_tf_loss,
	refseq_lut=refseq_lut,
	refseq_lut_file=NULL, # set below: refseq_lut_file
	refseq_name=refseq_name,
	tf_loss_cutoff=NULL, # set below: tf_loss_cutoff
	selected_sites=NULL,
        included_sites=NULL,
        excluded_sites=NULL
    )

    class(retval) <- "swarmtools"

    ### TO DO: invoke accessor methods for defined attributes
    if (!is.null(excluded_sites))
	retval <- set.excluded.sites(retval, excluded_sites)

    if (!is.null(included_sites))
	retval <- set.included.sites(retval, included_sites)

    # TO DO: make refseq lut optional - where is it required?
    # could simply use TF sequence instead
    if (!is.null(refseq_lut_file) & is.null(refseq_lut))
        retval$refseq_lut_file = refseq_lut_file

    ### This attempts to parse timepoint labels from sequence names
    ### before refseq is excluded from the alignment
    if (!is.null(aas_file) | !is.null(aas_aln))
	retval <- set.alignment(retval, aas_aln, aas_file)

# prep.aln is called by set.alignment#.file
# set.refseq is called by prep.aln
# excise.refseq is called by set.refseq
# set.tf is called by prep.aln

    if (!is.null(tf_loss_cutoff))
	retval <- set.tf.loss.cutoff(retval, tf_loss_cutoff)
# select.sites is called by set.tf.loss

    retval
}
