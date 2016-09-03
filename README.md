# trade
I propose two R programs for the exploitation of matrix of trade download on the WITS website
http://wits.worldbank.org/

## pgm_wits_data_load.R

The aim of this program is to transform the raw data extracted from WITS application in a more coherent trade matrix with a minimum of empty cells. The program introduce a set of rule of decision for the completion of flows Fij (trade flows from country i to country j)
* When Fij is declared by the country of origin (i declare export to j) and by the country of destination (j declare import from i) the values may be different and we have to decide what is the value assigned to Fij between Fij_i (point of view of the exporter) and Fij_j (point of view of the importer.
* When Fij is unknown from both origin an destination, we can decide to put the value to 0 or NA. But we can also imagine the existence of a symmetry and choose the value of the reverse flow Fji (which can be known according to exportation of j or according to importation of i).
They are a lot of possible options and the program can be adapted according to researcher's choice. We have provided as example an extraction of trade flows in 2009. 

## pgm_wits_data_gravity_model.R

The aim of this program is to build a classical gravity model based on two groups of factors related to size or proximity
* the introduction of size effects at origin and destination like Gross Domestic Product (GDP), Population (POP) or Area (SUP) of the country. We provide a set of data extracted from UNEP database for year 2009, but of course you can adapt to the year or the type of product.
* the introduction of proximity effects between countries of origin and destination can be based classically on euclidean distance (with many possible variantes) but also on contiguity (common border), cultural proximity (common language, official or not) and historical inheritage (colonial relation). As for size, a lot of options are possible and we just provide an example of data available on the website of the CEPII. 

## Improvement to be done

We have not controlled the coherence of the country codes used in the WITS database and in the other databases used as ancillary variables for the gravity model.


