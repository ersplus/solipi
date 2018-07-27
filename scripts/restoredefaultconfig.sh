#!/bin/bash
# Mon script
categories=`cat fichier.conf.orig  fichier.conf | sort | uniq`
echo $categories > fichier.conf


