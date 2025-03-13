rm(list = ls()) # Remove all the objects we created so far.

library(igraph) # Load the igraph package

nodes = read.csv('Dataset1-Media-Example-NODES.csv', header=T, as.is=T)
links = read.csv('Dataset1-Media-Example-EDGES.csv', header=T, as.is=T)


head(nodes)
head(links)

nrow(nodes); length(unique(nodes$id))
nrow(links); nrow(unique(links[,c("from", "to")]))

links[,3]
links[,-3]                  

links = aggregate(links[,3], links[-3], sum)
links = links[order(links$from, links$to),]
links

colnames(links)[4] = "weight"
rownames(links) = NULL
rownames(links)

nodes2 = read.csv('Dataset2-Media-User-Example-NODES.csv', header=T, as.is=T)
links2 = read.csv('Dataset2-Media-User-Example-EDGES.csv', header=T, row.names=1)

head(nodes2)
head(links2)

links2 = as.matrix(links2)
dim(links2)
dim(nodes2)

net = graph_from_data_frame(d=links, vertices=nodes, directed=T)

class(net)
net

E(net)
E(net)
V(net)
E(net)$type
V(net)$media

plot(net, edge.arrow.size=.4, vertex.label=NA)
net = simplify(net, remove.multiple=F, remove.loops = T)

as_edgelist(net, names=T)

as_adjacency_matrix(net, attr='weight')

as_data_frame(net, what='edges')
as_data_frame(net, what="vertices")

net2 = graph_from_incidence_matrix(links2)
table(V(net2)$type)

V(net2)
summary(net2)
net2.bp = bipartite_projection(net2)
net2.bp

plot(net2, vertex.label.color="black", vertex.label.dist=1,
     vertex.size=7, vertex.label=nodes2$media[!is.na(nodes2$media.type)])


plot(net2.bp$proj1, vertex.label.color="black", vertex.label.dist=1,
     vertex.size=7, vertex.label=nodes2$media[!is.na(nodes2$media.type)])

plot(net2.bp$proj2, vertex.label.color="black", vertex.label.dist=1,
     vertex.size=7, vertex.label=nodes2$media[!is.na(nodes2$media.type)])

########## BARABASI ALBERT #############

net.bg = sample_pa(80)
V(net.bg)$size = 8
V(net.bg)$frame.color = "white"
V(net.bg)$color = "orange"
V(net.bg)$label = ""
E(net.bg)$arrow.mode = 0

plot(net.bg)
plot(net.bg, layout=layout_randomly)
l = layout_in_circle(net.bg)
plot(net.bg, layout=l)

l2 <- cbind(1:vcount(net.bg), c(1, vcount(net.bg):2))
plot(net.bg, layout=l2)


plot(net.bg, layout=layout_on_sphere)
plot(net.bg, layout=layout_on_grid)


l <- layout_with_fr(net.bg)

plot(net.bg, layout=l)

par(mfrow=c(2,2), mar=c(0,0,0,0))
plot(net.bg, layout=layout_with_fr)

plot(net.bg, layout=layout_with_fr)

plot(net.bg, layout=l)

plot(net.bg, layout=l)
dev.off()

l <- layout_with_fr(net.bg)

l <- norm_coords(l, ymin=-1, ymax=1, xmin=-1, xmax=1)



par(mfrow=c(2,2), mar=c(0,0,0,0))

plot(net.bg, rescale=F, layout=l*0.4)

plot(net.bg, rescale=F, layout=l*0.6)

plot(net.bg, rescale=F, layout=l*0.8)

plot(net.bg, rescale=F, layout=l*1.0)

