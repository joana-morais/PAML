##########################################################
# Remove genes not present in all sequences              #  
# Joana Morais                                           #
# 20.03.2025                                             #
##########################################################

awk '
BEGIN {remove = 0}
/^>/ {
  remove = 0;
  header = tolower($0);  # Convert entire header to lowercase for case-insensitive matching

  if (header ~ /hoxd8/ || header ~ /hoxc11/ || header ~ /hoxb8/ || header ~ /hoxb5/) {
    remove = 1;
  } else {
    print;
  }
  next;
}
{
  if (!remove) print;
}' input_fasta.fasta > filtered_fasta.fasta




##Will remove HOX: hoxd8, hoxc11, hoxb8, hoxb5 => are the ones not present in everybody!